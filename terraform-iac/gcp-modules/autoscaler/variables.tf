variable "project_id" {
  type = string
}

variable "name" {
  type = string
}

variable "region" {
  type = string
}

variable "instance_group_manager" {
  description = "Self link of the MIG to autoscale"
  type        = string
}

variable "min_replicas" {
  type = number
}

variable "max_replicas" {
  type = number
}

variable "cooldown_period" {
  type    = number
  default = 60
}

variable "mode" {
  description = "Autoscaling mode: ON, ONLY_UP, or OFF"
  type        = string
  default     = "ON"
}

variable "cpu_target" {
  description = "Target CPU utilization (0.0–1.0)"
  type        = number
  default     = 0.6
}
