variable "role_name" {
  description = "Name of the IAM role"
  type        = string
}

variable "assume_role_policy" {
  description = "JSON assume role policy document"
  type        = string
}

variable "managed_policy_arns" {
  description = "List of managed policy ARNs to attach"
  type        = list(string)
  default     = []
}

variable "inline_policy" {
  description = "Inline policy JSON document"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags to apply to the IAM role"
  type        = map(string)
  default     = {}
}
