variable "name" {
  description = "Name of the Redis Cache instance"
  type        = string
}

variable "location" {
  description = "Azure region for Redis Cache"
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group where Redis Cache will be created"
  type        = string
}

variable "capacity" {
  description = "Redis Cache capacity (0–6 depending on SKU)"
  type        = number
  default     = 1
}

variable "family" {
  description = "Redis family (C for Basic/Standard, P for Premium)"
  type        = string
  default     = "C"
}

variable "sku_name" {
  description = "SKU name (Basic, Standard, Premium)"
  type        = string
  default     = "Standard"
}

variable "enable_non_ssl_port" {
  description = "Enable non-SSL port"
  type        = bool
  default     = false
}

variable "minimum_tls_version" {
  description = "Minimum TLS version"
  type        = string
  default     = "1.2"
}

variable "redis_config" {
  description = "Redis configuration settings"
  type = object({
    maxmemory_reserved = number
    maxmemory_delta    = number
    maxmemory_policy   = string
  })
  default = {
    maxmemory_reserved = 0
    maxmemory_delta    = 0
    maxmemory_policy   = "volatile-lru"
  }
}

variable "tags" {
  description = "Tags to apply to Redis Cache"
  type        = map(string)
  default     = {}
}
