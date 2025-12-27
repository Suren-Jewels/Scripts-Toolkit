variable "project_id" {
  type = string
}

variable "sink_name" {
  type = string
}

variable "destination" {
  description = "Logging sink destination (e.g., BigQuery, Pub/Sub, Storage)"
  type        = string
}

variable "filter" {
  description = "Log filter expression"
  type        = string
  default     = ""
}

variable "alert_policies" {
  description = "List of alert policies"
  type = list(object({
    display_name = string
    combiner     = string
    notification_channels = list(string)
    condition = object({
      display_name       = string
      filter             = string
      duration           = string
      comparison         = string
      threshold_value    = number
      alignment_period   = string
      per_series_aligner = string
    })
  }))
  default = []
}
