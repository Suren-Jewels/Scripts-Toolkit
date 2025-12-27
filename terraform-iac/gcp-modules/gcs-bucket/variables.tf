variable "project_id" {
  type = string
}

variable "name" {
  type = string
}

variable "location" {
  type    = string
  default = "US"
}

variable "storage_class" {
  type    = string
  default = "STANDARD"
}

variable "uniform_access" {
  type    = bool
  default = true
}

variable "versioning" {
  type    = bool
  default = false
}

variable "lifecycle_action" {
  type    = string
  default = "Delete"
}

variable "lifecycle_age" {
  type    = number
  default = 30
}

variable "labels" {
  type    = map(string)
  default = {}
}
