variable "project_id" {
  type = string
}

variable "name" {
  type = string
}

variable "region" {
  type = string
}

variable "tier" {
  description = "BASIC or STANDARD_HA"
  type        = string
  default     = "BASIC"
}

variable "memory_size_gb" {
  type = number
}

variable "vpc_self_link" {
  type = string
}

variable "redis_version" {
  type    = string
  default = "REDIS_6_X"
}

variable "transit_encryption_mode" {
  description = "SERVER_AUTHENTICATION or DISABLED"
  type        = string
  default     = "SERVER_AUTHENTICATION"
}

variable "labels" {
  type    = map(string)
  default = {}
}
