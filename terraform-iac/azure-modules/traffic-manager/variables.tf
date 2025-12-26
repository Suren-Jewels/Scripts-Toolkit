variable "name" {
  description = "Name of the Traffic Manager profile"
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group for Traffic Manager"
  type        = string
}

variable "routing_method" {
  description = "Traffic routing method (Performance, Priority, Weighted, Geographic)"
  type        = string
  default     = "Performance"
}

variable "relative_name" {
  description = "Relative DNS name for the Traffic Manager profile"
  type        = string
}

variable "ttl" {
  description = "DNS TTL"
  type        = number
  default     = 30
}

variable "monitor_protocol" {
  description = "Health probe protocol"
  type        = string
  default     = "HTTP"
}

variable "monitor_port" {
  description = "Health probe port"
  type        = number
  default     = 80
}

variable "monitor_path" {
  description = "Health probe path"
  type        = string
  default     = "/"
}

variable "endpoints" {
  description = "List of Traffic Manager endpoints"
  type = list(object({
    name     = string
    type     = string
    target   = string
    location = string
    priority = number
    weight   = number
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to Traffic Manager resources"
  type        = map(string)
  default     = {}
}
