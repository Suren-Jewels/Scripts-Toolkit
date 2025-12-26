variable "log_group_name" {
  description = "Name of the CloudWatch log group"
  type        = string
}

variable "retention_days" {
  description = "Retention period for logs"
  type        = number
  default     = 30
}

variable "metric_alarms" {
  description = "List of CloudWatch metric alarms"
  type = list(object({
    name                = string
    comparison_operator = string
    evaluation_periods  = number
    metric_name         = string
    namespace           = string
    period              = number
    statistic           = string
    threshold           = number
    description         = string
    alarm_actions       = list(string)
    ok_actions          = list(string)
    dimensions          = map(string)
  }))
  default = []
}

variable "enable_dashboard" {
  description = "Enable CloudWatch dashboard"
  type        = bool
  default     = false
}

variable "dashboard_name" {
  description = "Dashboard name"
  type        = string
  default     = ""
}

variable "dashboard_body" {
  description = "JSON body for the dashboard"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to CloudWatch resources"
  type        = map(string)
  default     = {}
}
