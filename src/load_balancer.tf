# Load Balancer
resource "azurerm_lb" "alb-01" {
  name                = "vmss-lb-01"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  sku                 = "Standard"
  frontend_ip_configuration {
    name                 = "LBFrontEnd"
    public_ip_address_id = azurerm_public_ip.public_ip.id
  }
}

# Backend address pool
resource "azurerm_lb_backend_address_pool" "vmss_lb_backend_pool" {
  loadbalancer_id     = azurerm_lb.alb-01.id
  name                = "BackEndAddressPool"
}

# NAT Pool
resource "azurerm_lb_nat_pool" "lbnatpool" {
  name                           = "RDP"
  resource_group_name            = data.azurerm_resource_group.main.name
  loadbalancer_id                = azurerm_lb.alb-01.id
  protocol                       = "Tcp"
  frontend_port_start            = 50000
  frontend_port_end              = 50005
  backend_port                   = 3389
  frontend_ip_configuration_name = "LBFrontEnd"
}
