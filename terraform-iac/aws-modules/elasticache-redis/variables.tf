variable "name" {
  description = "Name of the ElastiCache replication group"
  type        = string
}

variable "description" {
  description = "Description of the replication group"
  type        = string
  default     = "Redis replication group"
}

variable "engine_version" {
  description = "Redis engine version"
  type        = string
  default     = "7.0"
}

variable "node_type" {
  description = "Instance type for Redis nodes"
  type        = string
  default     = "cache.t3.micro"
}

variable "node_count" {
  description = "Number of cache nodes"
  type        = number
  default     = 1
}

variable "family" {
  description = "Parameter group family (e.g., redis7)"
  type        = string
  default     = "redis7"
}

variable "port" {
  description = "Redis port"
  type        = number
  default     = 6379
}

variable "automatic_failover" {
  description = "Enable automatic failover"
  type        = bool
  default     = false
}

variable "multi_az" {
  description = "Enable Multi-AZ"
  type        = bool
  default     = false
}

variable "at_rest_encryption" {
  description = "Enable encryption at rest"
  type        = bool
  default     = true
}

variable "transit_encryption" {
  description = "Enable encryption in transit"
  type        = bool
  default     = true
}

variable "subnet_ids" {
  description = "Subnets for ElastiCache"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security groups for Redis"
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply to ElastiCache resources"
  type        = map(string)
  default     = {}
}
