variable "project_id" {
  type = string
}

variable "name" {
  type = string
}

variable "region" {
  type = string
}

variable "database_version" {
  description = "Example: POSTGRES_14, MYSQL_8_0"
  type        = string
}

variable "tier" {
  description = "Machine tier (e.g., db-f1-micro, db-custom-2-4096)"
  type        = string
}

variable "availability_type" {
  description = "ZONAL or REGIONAL"
  type        = string
  default     = "ZONAL"
}

variable "public_ip" {
  type    = bool
  default = false
}

variable "private_network" {
  description = "Self link of VPC for private IP"
  type        = string
  default     = null
}

variable "require_ssl" {
  type    = bool
  default = true
}

variable "backup_enabled" {
  type    = bool
  default = true
}

variable "backup_start_time" {
  type    = string
  default = "03:00"
}

variable "point_in_time_recovery" {
  type    = bool
  default = false
}

variable "disk_size_gb" {
  type    = number
  default = 20
}

variable "disk_type" {
  type    = string
  default = "PD_SSD"
}

variable "disk_autoresize" {
  type    = bool
  default = true
}

variable "deletion_protection" {
  type    = bool
  default = false
}

variable "db_user" {
  type = string
}

variable "db_password" {
  type = string
}

variable "db_name" {
  type = string
}

variable "labels" {
  type    = map(string)
  default = {}
}
