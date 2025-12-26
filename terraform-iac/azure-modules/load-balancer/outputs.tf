output "lb_id" {
  value = azurerm_lb.this.id
}

output "lb_frontend_ip" {
  value = var.enable_public_ip ? azurerm_public_ip.lb_public_ip[0].ip_address : null
}

output "backend_pool_id" {
  value = azurerm_lb_backend_address_pool.backend_pool.id
}
