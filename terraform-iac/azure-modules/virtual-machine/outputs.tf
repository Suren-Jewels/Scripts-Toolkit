output "vm_id" {
  value = azurerm_linux_virtual_machine.this.id
}

output "vm_name" {
  value = azurerm_linux_virtual_machine.this.name
}

output "vm_private_ip" {
  value = azurerm_linux_virtual_machine.this.private_ip_address
}
