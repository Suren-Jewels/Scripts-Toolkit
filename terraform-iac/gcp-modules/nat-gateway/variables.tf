variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "name" {
  description = "Base name for NAT and router"
  type        = string
}

variable "region" {
  description = "Region for NAT gateway"
  type        = string
}

variable "vpc_self_link" {
  description = "Self link of the VPC network"
  type        = string
}

variable "subnet_self_links" {
  description = "List of subnet self links to NAT"
  type        = list(string)
}

variable "allocate_external_ips" {
  description = "Whether to auto-allocate external IPs"
  type        = bool
  default     = true
}

variable "labels" {
  description = "Labels to apply to NAT resources"
  type        = map(string)
  default     = {}
}
