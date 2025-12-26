variable "name" {
  description = "Name of the Azure Firewall"
  type        = string
}

variable "location" {
  description = "Azure region for the Firewall"
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group where the Firewall will be created"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for AzureFirewallSubnet"
  type        = string
}

variable "sku_name" {
  description = "Firewall SKU name"
  type        = string
  default     = "AZFW_VNet"
}

variable "sku_tier" {
  description = "Firewall SKU tier"
  type        = string
  default     = "Standard"
}

variable "network_rules" {
  description = "List of network rule collections"
  type = list(object({
    name                  = string
    priority              = number
    action                = string
    rule_name             = string
    source_addresses      = list(string)
    destination_addresses = list(string)
    destination_ports     = list(string)
    protocols             = list(string)
  }))
  default = []
}

variable "application_rules" {
  description = "List of application rule collections"
  type = list(object({
    name             = string
    priority         = number
    action           = string
    rule_name        = string
    source_addresses = list(string)
    target_fqdns     = list(string)
    protocol_port    = number
    protocol_type    = string
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to Firewall resources"
  type        = map(string)
  default     = {}
}
