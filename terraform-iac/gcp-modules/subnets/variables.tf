variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "vpc_self_link" {
  description = "Self link of the VPC network"
  type        = string
}

variable "subnets" {
  description = "List of subnet configurations"
  type = list(object({
    name                 = string
    cidr                 = string
    region               = string
    private_google_access = bool
  }))
}

variable "labels" {
  description = "Labels to apply to subnets"
  type        = map(string)
  default     = {}
}
