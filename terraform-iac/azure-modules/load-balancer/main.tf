resource "azurerm_public_ip" "lb_public_ip" {
  count               = var.enable_public_ip ? 1 : 0
  name                = "${var.name}-public-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}

resource "azurerm_lb" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "LoadBalancerFrontEnd"
    public_ip_address_id = var.enable_public_ip ? azurerm_public_ip.lb_public_ip[0].id : null
    subnet_id            = var.enable_public_ip ? null : var.subnet_id
  }

  tags = var.tags
}

resource "azurerm_lb_backend_address_pool" "backend_pool" {
  name                = "${var.name}-backend-pool"
  loadbalancer_id     = azurerm_lb.this.id
  resource_group_name = var.resource_group_name
}

resource "azurerm_lb_probe" "probe" {
  count               = var.enable_probe ? 1 : 0
  name                = "${var.name}-probe"
  loadbalancer_id     = azurerm_lb.this.id
  resource_group_name = var.resource_group_name
  protocol            = var.probe_protocol
  port                = var.probe_port
}

resource "azurerm_lb_rule" "lb_rule" {
  name                           = "${var.name}-rule"
  loadbalancer_id                = azurerm_lb.this.id
  resource_group_name            = var.resource_group_name
  protocol                       = var.lb_protocol
  frontend_port                  = var.frontend_port
  backend_port                   = var.backend_port
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.backend_pool.id]
  probe_id                       = var.enable_probe ? azurerm_lb_probe.probe[0].id : null
}
