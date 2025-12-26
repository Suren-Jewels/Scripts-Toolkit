variable "vpc_id" {
  description = "VPC ID where endpoints will be created"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "subnet_ids" {
  description = "Subnets for interface endpoints"
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "Security groups for interface endpoints"
  type        = list(string)
  default     = []
}

variable "route_table_ids" {
  description = "Route tables for gateway endpoints"
  type        = list(string)
  default     = []
}

variable "interface_endpoints" {
  description = "List of interface endpoint services (e.g., ['ssm', 'ec2messages'])"
  type        = list(string)
  default     = []
}

variable "gateway_endpoints" {
  description = "List of gateway endpoint services (e.g., ['s3', 'dynamodb'])"
  type        = list(string)
  default     = []
}

variable "private_dns_enabled" {
  description = "Enable private DNS for interface endpoints"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to VPC endpoint resources"
  type        = map(string)
  default     = {}
}
