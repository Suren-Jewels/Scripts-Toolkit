resource "azurerm_traffic_manager_profile" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  traffic_routing_method = var.routing_method

  dns_config {
    relative_name = var.relative_name
    ttl           = var.ttl
  }

  monitor_config {
    protocol = var.monitor_protocol
    port     = var.monitor_port
    path     = var.monitor_path
  }

  tags = var.tags
}

resource "azurerm_traffic_manager_endpoint" "endpoints" {
  count               = length(var.endpoints)
  name                = var.endpoints[count.index].name
  profile_name        = azurerm_traffic_manager_profile.this.name
  resource_group_name = var.resource_group_name
  type                = var.endpoints[count.index].type
  target              = var.endpoints[count.index].target
  endpoint_location   = var.endpoints[count.index].location
  priority            = var.endpoints[count.index].priority
  weight              = var.endpoints[count.index].weight
}
