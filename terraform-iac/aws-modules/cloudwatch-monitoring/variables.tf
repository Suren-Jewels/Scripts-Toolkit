variable "name" {
  description = "Base name for CloudWatch resources"
  type        = string
}

variable "instance_id" {
  description = "EC2 instance ID for CPU alarm"
  type        = string
}

variable "cpu_threshold" {
  description = "CPU threshold for alarm"
  type        = number
  default     = 80
}

variable "alarm_actions" {
  description = "List of ARNs to notify when alarm triggers"
  type        = list(string)
  default     = []
}

variable "ok_actions" {
  description = "List of ARNs to notify when alarm returns to OK"
  type        = list(string)
  default     = []
}

variable "log_retention_days" {
  description = "Retention period for CloudWatch log group"
  type        = number
  default     = 30
}

variable "dashboard_body" {
  description = "JSON body for CloudWatch dashboard"
  type        = string
  default     = "{}"
}

variable "tags" {
  description = "Additional tags to apply"
  type        = map(string)
  default     = {}
}
