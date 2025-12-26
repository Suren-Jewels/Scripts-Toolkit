resource "azurerm_storage_account" "this" {
  name                     = var.name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.replication_type
  account_kind             = var.account_kind
  enable_https_traffic_only = true

  tags = var.tags
}

resource "azurerm_storage_container" "containers" {
  count                 = length(var.containers)
  name                  = var.containers[count.index]
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"
}
