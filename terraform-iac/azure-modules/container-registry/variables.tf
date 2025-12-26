variable "name" {
  description = "Name of the Azure Container Registry (must be globally unique)"
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group where the ACR will be created"
  type        = string
}

variable "location" {
  description = "Azure region for the ACR"
  type        = string
}

variable "sku" {
  description = "ACR SKU (Basic, Standard, Premium)"
  type        = string
  default     = "Standard"
}

variable "admin_enabled" {
  description = "Enable admin user"
  type        = bool
  default     = false
}

variable "replication_locations" {
  description = "List of regions for geo-replication"
  type        = list(string)
  default     = []
}

variable "zone_redundancy_enabled" {
  description = "Enable zone redundancy for replications"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to ACR resources"
  type        = map(string)
  default     = {}
}

