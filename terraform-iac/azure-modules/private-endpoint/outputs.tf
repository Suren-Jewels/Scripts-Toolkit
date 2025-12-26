output "private_endpoint_id" {
  value = azurerm_private_endpoint.this.id
}

output "private_endpoint_nic" {
  value = azurerm_private_endpoint.this.network_interface[0].id
}

output "dns_zone_group_id" {
  value = length(var.private_dns_zone_ids) > 0 ? azurerm_private_dns_zone_group.dns_zone_group[0].id : null
}
