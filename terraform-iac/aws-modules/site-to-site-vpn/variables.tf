variable "vpc_id" {
  description = "VPC ID where the VPN Gateway will be attached"
  type        = string
}

variable "customer_gateway_ip" {
  description = "Public IP of the customer gateway device"
  type        = string
}

variable "customer_gateway_bgp_asn" {
  description = "BGP ASN for the customer gateway"
  type        = number
  default     = 65000
}

variable "static_routes_only" {
  description = "Use static routes instead of BGP"
  type        = bool
  default     = true
}

variable "route_destinations" {
  description = "List of destination CIDR blocks for static routes"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to VPN resources"
  type        = map(string)
  default     = {}
}
