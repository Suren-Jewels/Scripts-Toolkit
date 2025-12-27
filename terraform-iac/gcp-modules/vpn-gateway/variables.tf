variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "name" {
  description = "Name of the VPN gateway"
  type        = string
}

variable "region" {
  description = "Region for the VPN gateway"
  type        = string
}

variable "vpc_self_link" {
  description = "Self link of the VPC network"
  type        = string
}

variable "tunnels" {
  description = "List of VPN tunnel configurations"
  type = list(object({
    name                    = string
    peer_ip                 = string
    shared_secret           = string
    ike_version             = number
    local_traffic_selector  = list(string)
    remote_traffic_selector = list(string)
  }))
  default = []
}

variable "labels" {
  description = "Labels to apply to VPN resources"
  type        = map(string)
  default     = {}
}
