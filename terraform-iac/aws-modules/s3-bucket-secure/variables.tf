variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "enable_versioning" {
  description = "Enable S3 bucket versioning"
  type        = bool
  default     = true
}

variable "sse_algorithm" {
  description = "Server-side encryption algorithm"
  type        = string
  default     = "AES256"
}

variable "kms_key_id" {
  description = "KMS key ID for SSE-KMS encryption"
  type        = string
  default     = null
}

variable "enable_lifecycle" {
  description = "Enable lifecycle rules"
  type        = bool
  default     = false
}

variable "lifecycle_transition_days" {
  description = "Days before transitioning objects to IA storage"
  type        = number
  default     = 30
}

variable "lifecycle_expiration_days" {
  description = "Days before expiring objects"
  type        = number
  default     = 365
}

variable "tags" {
  description = "Additional tags to apply"
  type        = map(string)
  default     = {}
}
