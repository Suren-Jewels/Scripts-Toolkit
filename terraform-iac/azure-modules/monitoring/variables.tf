variable "workspace_name" {
  description = "Name of the Log Analytics Workspace"
  type        = string
}

variable "location" {
  description = "Azure region for the workspace"
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group where monitoring resources will be created"
  type        = string
}

variable "workspace_sku" {
  description = "SKU for the Log Analytics Workspace"
  type        = string
  default     = "PerGB2018"
}

variable "retention_days" {
  description = "Retention period for logs"
  type        = number
  default     = 30
}

variable "diagnostic_targets" {
  description = "List of resource IDs to attach diagnostic settings to"
  type        = list(string)
  default     = []
}

variable "logs" {
  description = "List of log categories to enable"
  type        = list(string)
  default     = []
}

variable "metrics" {
  description = "List of metric categories to enable"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to monitoring resources"
  type        = map(string)
  default     = {}
}
