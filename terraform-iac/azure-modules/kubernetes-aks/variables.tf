variable "name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "location" {
  description = "Azure region for the AKS cluster"
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group where AKS will be created"
  type        = string
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = null
}

variable "identity_type" {
  description = "Identity type (SystemAssigned or UserAssigned)"
  type        = string
  default     = "SystemAssigned"
}

variable "network_plugin" {
  description = "Network plugin (azure or kubenet)"
  type        = string
  default     = "azure"
}

variable "load_balancer_sku" {
  description = "Load balancer SKU"
  type        = string
  default     = "standard"
}

variable "dns_service_ip" {
  description = "DNS service IP"
  type        = string
  default     = "10.0.0.10"
}

variable "service_cidr" {
  description = "Service CIDR"
  type        = string
  default     = "10.0.0.0/16"
}

variable "docker_bridge_cidr" {
  description = "Docker bridge CIDR"
  type        = string
  default     = "172.17.0.1/16"
}

variable "node_pool" {
  description = "Default node pool configuration"
  type = object({
    name                = string
    vm_size             = string
    node_count          = number
    os_disk_size_gb     = number
    subnet_id           = string
    enable_auto_scaling = bool
    min_count           = number
    max_count           = number
  })
}

variable "additional_node_pools" {
  description = "List of additional node pools"
  type = list(object({
    name                = string
    vm_size             = string
    node_count          = number
    os_disk_size_gb     = number
    subnet_id           = string
    enable_auto_scaling = bool
    min_count           = number
    max_count           = number
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to AKS resources"
  type        = map(string)
  default     = {}
}
