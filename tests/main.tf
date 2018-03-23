# Here is the code which actually creates a resources using the module

module "sandbox-test-vm" {
  source                      = "../module"
  vm_name                     = "sandbox-test-vm"
  resource_group              = "${azurerm_resource_group.test.name}"
  subnet_id                   = "${azurerm_subnet.test.id}"
  avset_id                    = "${azurerm_availability_set.test.id}"
  storage_account             = "${azurerm_storage_account.test.name}"
  diagnostics_storage_account = "${azurerm_storage_account.test.name}"
  location                    = "${var.azure_region}"
  vm_size                     = "Standard_B1s"
  instance_count              = 1
  ssh_key                     = "${var.ssh_pubkey}"
  product                     = "sandbox"
  env                         = "sandbox"
}
