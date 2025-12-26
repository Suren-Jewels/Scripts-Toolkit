resource "azurerm_public_ip" "appgw_public_ip" {
  count               = var.enable_public_ip ? 1 : 0
  name                = "${var.name}-public-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}

resource "azurerm_application_gateway" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  sku {
    name     = var.sku_name
    tier     = var.sku_tier
    capacity = var.capacity
  }

  gateway_ip_configuration {
    name      = "appgw-ip-config"
    subnet_id = var.subnet_id
  }

  frontend_port {
    name = "frontend-port"
    port = var.frontend_port
  }

  frontend_ip_configuration {
    name                 = "frontend-ip"
    public_ip_address_id = var.enable_public_ip ? azurerm_public_ip.appgw_public_ip[0].id : null
    subnet_id            = var.enable_public_ip ? null : var.subnet_id
  }

  backend_address_pool {
    name = "backend-pool"
    backend_addresses = [
      for ip in var.backend_ips : { ip_address = ip }
    ]
  }

  backend_http_settings {
    name                  = "backend-http-settings"
    cookie_based_affinity = "Disabled"
    port                  = var.backend_port
    protocol              = var.backend_protocol
    request_timeout       = 30
  }

  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "frontend-ip"
    frontend_port_name             = "frontend-port"
    protocol                       = var.listener_protocol
  }

  request_routing_rule {
    name                       = "routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "http-listener"
    backend_address_pool_name  = "backend-pool"
    backend_http_settings_name = "backend-http-settings"
  }

  tags = var.tags
}
