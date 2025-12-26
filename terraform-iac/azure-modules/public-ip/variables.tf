variable "name" {
  description = "Name of the Public IP resource"
  type        = string
}

variable "location" {
  description = "Azure region for the Public IP"
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group where the Public IP will be created"
  type        = string
}

variable "allocation_method" {
  description = "IP allocation method (Static or Dynamic)"
  type        = string
  default     = "Static"
}

variable "sku" {
  description = "Public IP SKU (Basic or Standard)"
  type        = string
  default     = "Standard"
}

variable "tags" {
  description = "Tags to apply to the Public IP"
  type        = map(string)
  default     = {}
}
