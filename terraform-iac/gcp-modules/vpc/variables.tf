variable "name" {
  description = "Name of the VPC network"
  type        = string
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "routing_mode" {
  description = "Routing mode: GLOBAL or REGIONAL"
  type        = string
  default     = "GLOBAL"
}

variable "labels" {
  description = "Labels to apply to the VPC"
  type        = map(string)
  default     = {}
}
