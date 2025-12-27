variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "vpc_self_link" {
  description = "Self link of the VPC network"
  type        = string
}

variable "rules" {
  description = "List of firewall rule configurations"
  type = list(object({
    name                = string
    direction           = string
    priority            = number
    disabled            = bool
    allow = object({
      protocol = string
      ports    = list(string)
    })
    source_ranges      = list(string)
    destination_ranges = list(string)
    target_tags        = list(string)
    source_tags        = list(string)
  }))
}

variable "labels" {
  description = "Labels to apply to firewall rules"
  type        = map(string)
  default     = {}
}
