output "nic_id" {
  value = azurerm_network_interface.this.id
}

output "nic_private_ip" {
  value = azurerm_network_interface.this.private_ip_address
}

output "nic_name" {
  value = azurerm_network_interface.this.name
}
