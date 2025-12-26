variable "name" {
  description = "Name of the App Service"
  type        = string
}

variable "location" {
  description = "Azure region for the App Service"
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group where the App Service will be created"
  type        = string
}

variable "plan_kind" {
  description = "Kind of App Service Plan (Linux or Windows)"
  type        = string
  default     = "Linux"
}

variable "sku_tier" {
  description = "App Service Plan SKU tier"
  type        = string
  default     = "Basic"
}

variable "sku_size" {
  description = "App Service Plan SKU size"
  type        = string
  default     = "B1"
}

variable "always_on" {
  description = "Enable Always On"
  type        = bool
  default     = true
}

variable "linux_fx_version" {
  description = "Runtime stack (e.g., DOCKER|nginx:latest)"
  type        = string
  default     = null
}

variable "use_32_bit_worker" {
  description = "Use 32-bit worker process"
  type        = bool
  default     = false
}

variable "app_settings" {
  description = "App settings for the App Service"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags to apply to App Service resources"
  type        = map(string)
  default     = {}
}
