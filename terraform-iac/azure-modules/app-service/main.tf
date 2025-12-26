resource "azurerm_app_service_plan" "this" {
  name                = "${var.name}-plan"
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = var.plan_kind

  sku {
    tier = var.sku_tier
    size = var.sku_size
  }

  tags = var.tags
}

resource "azurerm_app_service" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  app_service_plan_id = azurerm_app_service_plan.this.id

  site_config {
    always_on                 = var.always_on
    linux_fx_version          = var.linux_fx_version
    use_32_bit_worker_process = var.use_32_bit_worker
  }

  app_settings = var.app_settings

  tags = var.tags
}
