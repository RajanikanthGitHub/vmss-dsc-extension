# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "shd-sbx-nrk-uks-vnet"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  address_space       = ["10.0.0.0/16"]
  depends_on = [
    data.azurerm_resource_group.main
  ]
}

# Subnet
resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = data.azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
  depends_on = [
    azurerm_virtual_network.main
  ]
}

# Public IP
resource "azurerm_public_ip" "public_ip" {
  name                = "shd-sbx-nrk-pip"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  allocation_method   = "Static"
  sku                 = "Standard"
}