resource "azurerm_redis_cache" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  capacity            = var.capacity
  family              = var.family
  sku_name            = var.sku_name
  enable_non_ssl_port = var.enable_non_ssl_port
  minimum_tls_version = var.minimum_tls_version

  redis_configuration {
    maxmemory_reserved = var.redis_config.maxmemory_reserved
    maxmemory_delta    = var.redis_config.maxmemory_delta
    maxmemory_policy   = var.redis_config.maxmemory_policy
  }

  tags = var.tags
}
