variable "name" {
  description = "Name of the Application Gateway"
  type        = string
}

variable "location" {
  description = "Azure region for the Application Gateway"
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group where the Application Gateway will be created"
  type        = string
}

variable "enable_public_ip" {
  description = "Whether to create a Public IP for the Application Gateway"
  type        = bool
  default     = true
}

variable "subnet_id" {
  description = "Subnet ID for the Application Gateway"
  type        = string
}

variable "sku_name" {
  description = "SKU name (e.g., WAF_v2, Standard_v2)"
  type        = string
  default     = "Standard_v2"
}

variable "sku_tier" {
  description = "SKU tier (Standard_v2 or WAF_v2)"
  type        = string
  default     = "Standard_v2"
}

variable "capacity" {
  description = "Instance count for the Application Gateway"
  type        = number
  default     = 2
}

variable "frontend_port" {
  description = "Frontend port"
  type        = number
  default     = 80
}

variable "backend_port" {
  description = "Backend port"
  type        = number
  default     = 80
}

variable "backend_protocol" {
  description = "Backend protocol (Http or Https)"
  type        = string
  default     = "Http"
}

variable "listener_protocol" {
  description = "Listener protocol (Http or Https)"
  type        = string
  default     = "Http"
}

variable "backend_ips" {
  description = "List of backend IP addresses"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to Application Gateway resources"
  type        = map(string)
  default     = {}
}
