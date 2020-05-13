resource "azurerm_virtual_network" "vnet" {
  name                = "${var.project_name}_vnet"
  address_space       = var.vnet_address
  location            = var.azure_region
  resource_group_name = var.resource_group
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.project_name}_${count.index}"
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix       = "10.0.${count.index}.0/24"
  count                = var.web_count
}

resource "azurerm_public_ip" "controller_public_ip" {
  name                = "${var.project_name}_controller"
  location            = var.azure_region
  resource_group_name = var.resource_group
  allocation_method   = "Dynamic"
}

