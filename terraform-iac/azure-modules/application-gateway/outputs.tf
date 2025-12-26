output "app_gateway_id" {
  value = azurerm_application_gateway.this.id
}

output "app_gateway_frontend_ip" {
  value = var.enable_public_ip ? azurerm_public_ip.appgw_public_ip[0].ip_address : null
}

output "app_gateway_name" {
  value = azurerm_application_gateway.this.name
}
