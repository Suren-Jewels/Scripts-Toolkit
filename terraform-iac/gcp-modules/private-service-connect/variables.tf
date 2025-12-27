variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "name" {
  description = "Base name for PSC resources"
  type        = string
}

variable "vpc_self_link" {
  description = "Self link of the VPC network"
  type        = string
}

variable "subnet_self_link" {
  description = "Self link of the subnet for PSC endpoint"
  type        = string
}

variable "target_service" {
  description = "Target service URI for PSC (e.g., Google API or custom service)"
  type        = string
}

variable "ports" {
  description = "List of ports for PSC forwarding rule"
  type        = list(string)
}

variable "labels" {
  description = "Labels to apply to PSC resources"
  type        = map(string)
  default     = {}
}
