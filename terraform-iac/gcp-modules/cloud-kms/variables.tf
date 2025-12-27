variable "project_id" {
  type = string
}

variable "location" {
  type = string
}

variable "key_ring_name" {
  type = string
}

variable "crypto_key_name" {
  type = string
}

variable "rotation_period" {
  description = "Rotation period (e.g., '2592000s' for 30 days)"
  type        = string
  default     = "2592000s"
}

variable "prevent_destroy" {
  type    = bool
  default = false
}

variable "labels" {
  type    = map(string)
  default = {}
}
