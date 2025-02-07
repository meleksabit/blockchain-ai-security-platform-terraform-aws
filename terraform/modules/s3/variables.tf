variable "project_suffix" {
  description = "Suffix to make bucket names unique"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "s3_role_arn" {
  description = "IAM Role ARN for S3 access"
  type        = string
}
