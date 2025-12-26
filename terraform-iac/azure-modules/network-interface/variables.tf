variable "name" {
  description = "Name of the Network Interface"
  type        = string
}

variable "location" {
  description = "Azure region for the NIC"
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group where the NIC will be created"
  type        = string
}

variable "ip_config_name" {
  description = "Name of the IP configuration block"
  type        = string
  default     = "ipconfig1"
}

variable "subnet_id" {
  description = "Subnet ID for the NIC"
  type        = string
}

variable "private_ip_allocation" {
  description = "Private IP allocation method"
  type        = string
  default     = "Dynamic"
}

variable "private_ip" {
  description = "Static private IP address (if using Static allocation)"
  type        = string
  default     = null
}

variable "public_ip_id" {
  description = "Public IP resource ID to associate"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to the NIC"
  type        = map(string)
  default     = {}
}
