# Network Security Group
resource "azurerm_network_security_group" "main" {
  name                = "vmss_nsg"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
}

# NSG Rules
resource "azurerm_network_security_rule" "vmss_rdp_3389" {
  name                        = "vmss-rdp-3389"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
}

# Associate the NSG with the Subnet
resource "azurerm_subnet_network_security_group_association" "vmss-nsg-association" {
  subnet_id                 = azurerm_subnet.internal.id
  network_security_group_id = azurerm_network_security_group.main.id
}