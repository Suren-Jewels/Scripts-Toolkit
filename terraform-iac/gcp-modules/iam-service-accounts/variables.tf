variable "project_id" {
  type = string
}

variable "service_accounts" {
  description = "List of service accounts to create"
  type = list(object({
    account_id   = string
    display_name = string
  }))
}

variable "bindings" {
  description = "IAM role bindings for service accounts"
  type = list(object({
    sa_index = number
    role     = string
  }))
}
