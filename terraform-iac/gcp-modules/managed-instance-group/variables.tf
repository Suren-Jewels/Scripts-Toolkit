variable "project_id" {
  type = string
}

variable "name" {
  type = string
}

variable "region" {
  type = string
}

variable "machine_type" {
  type = string
}

variable "image" {
  type = string
}

variable "disk_size_gb" {
  type    = number
  default = 20
}

variable "disk_type" {
  type    = string
  default = "pd-balanced"
}

variable "subnet_self_link" {
  type = string
}

variable "assign_public_ip" {
  type    = bool
  default = false
}

variable "metadata" {
  type    = map(string)
  default = {}
}

variable "labels" {
  type    = map(string)
  default = {}
}

variable "tags" {
  type    = list(string)
  default = []
}

variable "target_size" {
  type = number
}

variable "health_check" {
  type = string
}

variable "initial_delay_sec" {
  type    = number
  default = 300
}
