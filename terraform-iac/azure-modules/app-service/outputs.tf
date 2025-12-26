output "app_service_id" {
  value = azurerm_app_service.this.id
}

output "app_service_default_hostname" {
  value = azurerm_app_service.this.default_site_hostname
}

output "app_service_plan_id" {
  value = azurerm_app_service_plan.this.id
}
