variable "name" {
  description = "Name of the Storage Account (must be globally unique)"
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group where the Storage Account will be created"
  type        = string
}

variable "location" {
  description = "Azure region for the Storage Account"
  type        = string
}

variable "account_tier" {
  description = "Storage account tier (Standard or Premium)"
  type        = string
  default     = "Standard"
}

variable "replication_type" {
  description = "Replication type (LRS, GRS, RAGRS, ZRS)"
  type        = string
  default     = "LRS"
}

variable "account_kind" {
  description = "Storage account kind (StorageV2 recommended)"
  type        = string
  default     = "StorageV2"
}

variable "containers" {
  description = "List of storage containers to create"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to the Storage Account"
  type        = map(string)
  default     = {}
}
