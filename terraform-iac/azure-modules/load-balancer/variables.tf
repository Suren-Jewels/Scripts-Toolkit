variable "name" {
  description = "Name of the Load Balancer"
  type        = string
}

variable "location" {
  description = "Azure region for the Load Balancer"
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group where the Load Balancer will be created"
  type        = string
}

variable "enable_public_ip" {
  description = "Whether to create a Public IP for the LB"
  type        = bool
  default     = true
}

variable "subnet_id" {
  description = "Subnet ID for internal load balancers"
  type        = string
  default     = null
}

variable "frontend_port" {
  description = "Frontend port for the LB rule"
  type        = number
}

variable "backend_port" {
  description = "Backend port for the LB rule"
  type        = number
}

variable "lb_protocol" {
  description = "Protocol for the LB rule"
  type        = string
  default     = "Tcp"
}

variable "enable_probe" {
  description = "Enable health probe"
  type        = bool
  default     = true
}

variable "probe_protocol" {
  description = "Probe protocol"
  type        = string
  default     = "Tcp"
}

variable "probe_port" {
  description = "Probe port"
  type        = number
  default     = 80
}

variable "tags" {
  description = "Tags to apply to the Load Balancer"
  type        = map(string)
  default     = {}
}
