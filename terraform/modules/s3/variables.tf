variable "project_suffix" {
  description = "Suffix to make bucket names unique"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "s3_bucket_name" {
  description = "S3 Bucket name for storing logs and AI models"
  type        = string
  default     = "blockchain-ai-logs"
}
