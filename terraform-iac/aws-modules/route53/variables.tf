variable "domain_name" {
  description = "Hosted zone domain name"
  type        = string
}

variable "record_name" {
  description = "DNS record name"
  type        = string
}

variable "record_type" {
  description = "DNS record type (A, CNAME, etc.)"
  type        = string
  default     = "A"
}

variable "ttl" {
  description = "Record TTL"
  type        = number
  default     = 60
}

variable "enable_failover" {
  description = "Enable failover routing"
  type        = bool
  default     = false
}

variable "primary_value" {
  description = "Primary record value"
  type        = string
  default     = ""
}

variable "secondary_value" {
  description = "Secondary record value"
  type        = string
  default     = ""
}

variable "enable_latency" {
  description = "Enable latency routing"
  type        = bool
  default     = false
}

variable "latency_records" {
  description = "Latency routing records"
  type = list(object({
    identifier = string
    region     = string
    value      = string
  }))
  default = []
}

variable "enable_weighted" {
  description = "Enable weighted routing"
  type        = bool
  default     = false
}

variable "weighted_records" {
  description = "Weighted routing records"
  type = list(object({
    identifier = string
    weight     = number
    value      = string
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to Route53 resources"
  type        = map(string)
  default     = {}
}
