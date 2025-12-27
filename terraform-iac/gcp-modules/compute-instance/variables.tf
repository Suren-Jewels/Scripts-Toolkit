variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "name" {
  description = "Name of the compute instance"
  type        = string
}

variable "machine_type" {
  description = "Machine type (e.g., e2-medium)"
  type        = string
}

variable "zone" {
  description = "Zone where the instance will run"
  type        = string
}

variable "image" {
  description = "Boot disk image"
  type        = string
}

variable "disk_size_gb" {
  description = "Boot disk size in GB"
  type        = number
  default     = 20
}

variable "disk_type" {
  description = "Boot disk type (pd-standard, pd-balanced, pd-ssd)"
  type        = string
  default     = "pd-balanced"
}

variable "subnet_self_link" {
  description = "Self link of the subnet"
  type        = string
}

variable "assign_public_ip" {
  description = "Whether to assign a public IP"
  type        = bool
  default     = false
}

variable "metadata" {
  description = "Instance metadata"
  type        = map(string)
  default     = {}
}

variable "labels" {
  description = "Labels to apply to the instance"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Network tags for firewall rules"
  type        = list(string)
  default     = []
}
