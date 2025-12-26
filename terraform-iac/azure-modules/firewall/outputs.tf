output "firewall_id" {
  value = azurerm_firewall.this.id
}

output "firewall_public_ip" {
  value = azurerm_public_ip.firewall_public_ip.ip_address
}

output "firewall_name" {
  value = azurerm_firewall.this.name
}
