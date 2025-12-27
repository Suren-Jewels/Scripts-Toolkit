variable "project_id" {
  type = string
}

variable "name" {
  type = string
}

variable "instance_group" {
  description = "Self link of backend instance group"
  type        = string
}

variable "port_name" {
  description = "Named port for backend service"
  type        = string
  default     = "http"
}

variable "timeout_sec" {
  type    = number
  default = 30
}

variable "health_check_port" {
  type    = number
  default = 80
}
