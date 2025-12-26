resource "azurerm_postgresql_flexible_server" "this" {
  name                   = var.name
  resource_group_name    = var.resource_group_name
  location               = var.location
  version                = var.engine_version
  administrator_login    = var.admin_username
  administrator_password = var.admin_password
  storage_mb             = var.storage_mb
  sku_name               = var.sku_name
  backup_retention_days  = var.backup_retention_days
  zone                   = var.zone
  high_availability {
    mode = var.ha_enabled ? "ZoneRedundant" : "Disabled"
  }

  network {
    delegated_subnet_id = var.subnet_id
    private_dns_zone_id = var.private_dns_zone_id
  }

  tags = var.tags
}

resource "azurerm_postgresql_flexible_server_database" "databases" {
  count      = length(var.databases)
  name       = var.databases[count.index]
  server_id  = azurerm_postgresql_flexible_server.this.id
  charset    = "UTF8"
  collation  = "en_US.utf8"
}
