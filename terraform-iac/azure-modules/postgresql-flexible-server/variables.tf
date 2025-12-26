variable "name" {
  description = "Name of the PostgreSQL Flexible Server"
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group where the server will be created"
  type        = string
}

variable "location" {
  description = "Azure region for the server"
  type        = string
}

variable "engine_version" {
  description = "PostgreSQL engine version"
  type        = string
  default     = "15"
}

variable "admin_username" {
  description = "Administrator username"
  type        = string
}

variable "admin_password" {
  description = "Administrator password"
  type        = string
  sensitive   = true
}

variable "sku_name" {
  description = "SKU name (e.g., Standard_D2s_v3)"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "storage_mb" {
  description = "Storage size in MB"
  type        = number
  default     = 32768
}

variable "backup_retention_days" {
  description = "Backup retention period"
  type        = number
  default     = 7
}

variable "zone" {
  description = "Availability zone"
  type        = string
  default     = null
}

variable "ha_enabled" {
  description = "Enable high availability"
  type        = bool
  default     = false
}

variable "subnet_id" {
  description = "Delegated subnet ID for the server"
  type        = string
}

variable "private_dns_zone_id" {
  description = "Private DNS zone ID for the server"
  type        = string
  default     = null
}

variable "databases" {
  description = "List of databases to create"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to the server"
  type        = map(string)
  default     = {}
}
