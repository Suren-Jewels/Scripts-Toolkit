variable "project_id" {
  type = string
}

variable "name" {
  type = string
}

variable "region" {
  type = string
}

variable "instance_group" {
  description = "Self link of backend instance group"
  type        = string
}

variable "port_range" {
  description = "Port or port range (e.g., '80' or '3000-3010')"
  type        = string
}

variable "timeout_sec" {
  type    = number
  default = 30
}

variable "health_check_port" {
  type    = number
  default = 80
}
