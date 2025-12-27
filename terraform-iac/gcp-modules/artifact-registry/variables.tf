variable "project_id" {
  type = string
}

variable "name" {
  type = string
}

variable "location" {
  type    = string
  default = "us-central1"
}

variable "format" {
  description = "Repository format: DOCKER, MAVEN, NPM, PYTHON, APT, YUM"
  type        = string
  default     = "DOCKER"
}

variable "description" {
  type    = string
  default = ""
}

variable "labels" {
  type    = map(string)
  default = {}
}
