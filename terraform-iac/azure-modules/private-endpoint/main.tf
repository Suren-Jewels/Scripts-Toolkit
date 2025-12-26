resource "azurerm_private_endpoint" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${var.name}-connection"
    private_connection_resource_id = var.target_resource_id
    subresource_names              = var.subresource_names
    is_manual_connection           = var.manual_connection
  }

  tags = var.tags
}

resource "azurerm_private_dns_zone_group" "dns_zone_group" {
  count               = length(var.private_dns_zone_ids) > 0 ? 1 : 0
  name                = "${var.name}-dns-zone-group"
  private_endpoint_id = azurerm_private_endpoint.this.id

  private_dns_zone_ids = var.private_dns_zone_ids
}
