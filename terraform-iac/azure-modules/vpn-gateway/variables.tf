variable "name" {
  description = "Name of the VPN Gateway"
  type        = string
}

variable "location" {
  description = "Azure region for the VPN Gateway"
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group where the VPN Gateway will be created"
  type        = string
}

variable "gateway_subnet_id" {
  description = "Subnet ID for the GatewaySubnet"
  type        = string
}

variable "vpn_type" {
  description = "VPN type (RouteBased or PolicyBased)"
  type        = string
  default     = "RouteBased"
}

variable "active_active" {
  description = "Enable active-active mode"
  type        = bool
  default     = false
}

variable "enable_bgp" {
  description = "Enable BGP"
  type        = bool
  default     = false
}

variable "bgp_asn" {
  description = "BGP ASN"
  type        = number
  default     = 65515
}

variable "sku" {
  description = "Gateway SKU (e.g., VpnGw1, VpnGw2)"
  type        = string
  default     = "VpnGw1"
}

variable "connections" {
  description = "List of VPN connections"
  type = list(object({
    name             = string
    type             = string
    local_gateway_id = string
    shared_key       = string
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to VPN Gateway resources"
  type        = map(string)
  default     = {}
}
