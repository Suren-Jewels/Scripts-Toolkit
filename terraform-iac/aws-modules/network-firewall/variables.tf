variable "name" {
  description = "Name of the Network Firewall"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the firewall will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "Subnets for firewall endpoints"
  type        = list(string)
}

variable "stateless_default_actions" {
  description = "Default stateless actions"
  type        = list(string)
  default     = ["aws:forward_to_sfe"]
}

variable "stateless_fragment_default_actions" {
  description = "Default stateless fragment actions"
  type        = list(string)
  default     = ["aws:forward_to_sfe"]
}

variable "stateless_rule_group_arns" {
  description = "List of stateless rule group ARNs"
  type        = list(string)
  default     = []
}

variable "stateful_rule_group_arns" {
  description = "List of stateful rule group ARNs"
  type        = list(string)
  default     = []
}

variable "s3_bucket_name" {
  description = "S3 bucket for firewall logs"
  type        = string
}

variable "tags" {
  description = "Tags to apply to Network Firewall resources"
  type        = map(string)
  default     = {}
}
