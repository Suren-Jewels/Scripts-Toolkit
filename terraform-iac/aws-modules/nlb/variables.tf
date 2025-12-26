variable "name" {
  description = "Name of the NLB"
  type        = string
}

variable "internal" {
  description = "Whether the NLB is internal"
  type        = bool
  default     = false
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID for the target group"
  type        = string
}

variable "listener_port" {
  description = "Listener port"
  type        = number
  default     = 80
}

variable "listener_protocol" {
  description = "Listener protocol"
  type        = string
  default     = "TCP"
}

variable "target_port" {
  description = "Target port"
  type        = number
  default     = 80
}

variable "target_protocol" {
  description = "Target protocol"
  type        = string
  default     = "TCP"
}

variable "target_type" {
  description = "Target type (instance, ip)"
  type        = string
  default     = "instance"
}

variable "health_check_protocol" {
  description = "Health check protocol"
  type        = string
  default     = "TCP"
}

variable "health_check_port" {
  description = "Health check port"
  type        = string
  default     = "traffic-port"
}

variable "health_check_interval" {
  description = "Health check interval"
  type        = number
  default     = 30
}

variable "health_check_healthy_threshold" {
  description = "Healthy threshold"
  type        = number
  default     = 3
}

variable "health_check_unhealthy_threshold" {
  description = "Unhealthy threshold"
  type        = number
  default     = 3
}

variable "tags" {
  description = "Tags to apply to NLB resources"
  type        = map(string)
  default     = {}
}
