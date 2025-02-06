variable "project_suffix" {
  description = "Suffix to make bucket names unique"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  default     = "prod"
}
