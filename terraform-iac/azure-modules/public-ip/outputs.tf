output "public_ip_id" {
  value = azurerm_public_ip.this.id
}

output "public_ip_address" {
  value = azurerm_public_ip.this.ip_address
}

output "public_ip_name" {
  value = azurerm_public_ip.this.name
}
