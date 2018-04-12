# The existing server modules were 90% the same and repeated so didn't want to use them
# this should fit all use cases and only one place to change code

# turn vm_name variable into vm_name with count at the end (2 numbers e.g. 01)
data "template_file" "server_name" {
  template = "$${prefix}${format("%02d", count.index + 1)}"

  count = "${var.instance_count}"

  vars {
    prefix = "${var.vm_name}"
  }
}

# Create Networking
resource "azurerm_network_interface" "reform-nonprod" {
  count               = "${var.instance_count}"
  name                = "${element(data.template_file.server_name.*.rendered, count.index)}-NIC"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group}"

  ip_configuration {
    name                          = "${element(data.template_file.server_name.*.rendered, count.index)}-NIC"
    subnet_id                     = "/subscriptions/${var.azure_subscription_id}/resourceGroups/${var.resource_group}/providers/Microsoft.Network/virtualNetworks/${var.vnet}/subnets/${var.subnet}"
    private_ip_address_allocation = "dynamic"
  }

  lifecycle {
    ignore_changes = ["name"]
  }
}

resource "random_string" "password" {
  length  = 20
  special = true
}

resource "azurerm_virtual_machine" "reform-nonprod" {
  count                 = "${var.instance_count}"
  name                  = "${element(data.template_file.server_name.*.rendered, count.index)}"
  location              = "${var.location}"
  resource_group_name   = "${var.resource_group}"
  network_interface_ids = ["${element(azurerm_network_interface.reform-nonprod.*.id, count.index)}"]
  vm_size               = "${var.vm_size}"
  availability_set_id   = "${var.avset_id}"

  delete_os_disk_on_termination    = "${var.delete_os_disk_on_termination}"
  delete_data_disks_on_termination = "${var.delete_data_disks_on_termination}"

  storage_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.3"
    version   = "latest"
  }

  storage_os_disk {
    name          = "${element(data.template_file.server_name.*.rendered, count.index)}"
    vhd_uri       = "https://${var.storage_account}.blob.core.windows.net/vhds/${element(data.template_file.server_name.*.rendered, count.index)}.vhd"
    caching       = "ReadWrite"
    create_option = "FromImage"
  }

  os_profile {
    computer_name  = "${element(data.template_file.server_name.*.rendered, count.index)}"
    admin_username = "${var.username}"
    admin_password = "${random_string.password.result}"
  }

  lifecycle {
    ignore_changes = ["os_profile", "name", "network_interface_ids"]
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.username}/.ssh/authorized_keys"
      key_data = "${var.ssh_key}"
    }
  }

  boot_diagnostics {
    enabled     = true
    storage_uri = "https://${var.diagnostics_storage_account}.blob.core.windows.net/"
  }

  tags {
    type      = "vm"
    product = "${lower("${var.product}")}"
    env     = "${lower("${var.env}")}"
    tier      = "${var.tier}"
    ansible   = "${var.ansible}"
    terraform = "true"
    role      = "${var.role}"
  }
}

resource "azurerm_virtual_machine_extension" "script" {
  count                = "${var.instance_count}"
  name                 = "${element(data.template_file.server_name.*.rendered, count.index)}"
  location             = "${var.location}"
  resource_group_name  = "${var.resource_group}"
  virtual_machine_name = "${element(data.template_file.server_name.*.rendered, count.index)}"
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"
  depends_on           = ["azurerm_virtual_machine.reform-nonprod"]

  settings = <<SETTINGS
    {
        "commandToExecute": "iptables -t nat -A PREROUTING -p tcp --dport 444 -j REDIRECT --to-ports 22; iptables-save > /etc/sysconfig/iptables"
    }
SETTINGS
}
