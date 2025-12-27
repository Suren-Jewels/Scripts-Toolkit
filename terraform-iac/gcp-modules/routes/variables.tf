variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "vpc_self_link" {
  description = "Self link of the VPC network"
  type        = string
}

variable "routes" {
  description = "List of route configurations"
  type = list(object({
    name        = string
    destination = string
    next_hop_ip = string
    priority    = number
    tags        = map(string)
  }))
}
