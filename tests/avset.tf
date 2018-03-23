resource "azurerm_availability_set" "test" {
  name                = "${var.test_name}-availability-set"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"

  tags {
    environment = "sandbox"
  }
}
