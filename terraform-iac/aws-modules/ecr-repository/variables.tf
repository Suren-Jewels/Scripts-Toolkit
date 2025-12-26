variable "name" {
  description = "Name of the ECR repository"
  type        = string
}

variable "image_tag_mutability" {
  description = "Image tag mutability setting"
  type        = string
  default     = "MUTABLE"
}

variable "force_delete" {
  description = "Allow force deletion of the repository"
  type        = bool
  default     = false
}

variable "encryption_type" {
  description = "Encryption type for ECR images"
  type        = string
  default     = "AES256"
}

variable "kms_key_id" {
  description = "KMS key ID for encryption (if using KMS)"
  type        = string
  default     = null
}

variable "scan_on_push" {
  description = "Enable image scanning on push"
  type        = bool
  default     = true
}

variable "enable_lifecycle_policy" {
  description = "Enable lifecycle policy for ECR"
  type        = bool
  default     = false
}

variable "lifecycle_policy_json" {
  description = "JSON lifecycle policy document"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags to apply"
  type        = map(string)
  default     = {}
}
