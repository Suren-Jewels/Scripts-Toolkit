variable "name" {
  description = "Name of the Private Endpoint"
  type        = string
}

variable "location" {
  description = "Azure region for the Private Endpoint"
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group where the Private Endpoint will be created"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the Private Endpoint"
  type        = string
}

variable "target_resource_id" {
  description = "Resource ID of the service to connect privately"
  type        = string
}

variable "subresource_names" {
  description = "Subresource names for the private connection (e.g., ['blob'])"
  type        = list(string)
}

variable "manual_connection" {
  description = "Whether the connection requires manual approval"
  type        = bool
  default     = false
}

variable "private_dns_zone_ids" {
  description = "List of Private DNS Zone IDs to associate"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to Private Endpoint resources"
  type        = map(string)
  default     = {}
}
