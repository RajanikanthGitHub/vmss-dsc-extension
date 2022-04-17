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
  depends_on = [
    azurerm_public_ip.public_ip
  ]
}

# Backend address pool
resource "azurerm_lb_backend_address_pool" "vmss_lb_backend_pool" {
  loadbalancer_id = azurerm_lb.alb-01.id
  name            = "BackEndAddressPool"
  depends_on = [
    azurerm_lb.alb-01
  ]
}

resource "azurerm_lb_rule" "lb-rule01" {
  name                           = "lb-rule01"
  loadbalancer_id                = azurerm_lb.alb-01.id
  protocol                       = "Tcp"
  frontend_port                  = 3389
  backend_port                   = 3389
  frontend_ip_configuration_name = "LBFrontEnd"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.vmss_lb_backend_pool.id]
}