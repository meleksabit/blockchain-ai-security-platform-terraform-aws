# -------------------------------
# RDS Database Configuration
# -------------------------------
variable "db_name" {
  description = "Name of the PostgreSQL database"
  type        = string
  default     = "blockchain_db"
}

variable "db_username" {
  description = "Master username for the PostgreSQL database"
  type        = string
}

variable "db_password" {
  description = "Master password for the PostgreSQL database"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "Instance type for RDS database"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Allocated storage in GB for the RDS instance"
  type        = number
  default     = 20
}

variable "db_engine_version" {
  description = "Version of PostgreSQL to use"
  type        = string
  default     = "15.4"
}

# -------------------------------
# Security Group Configuration
# -------------------------------
variable "rds_security_group_id" {
  description = "Security Group ID for the RDS instance"
  type        = string
}

# -------------------------------
# S3 Storage for AI Logs / Models
# -------------------------------
variable "s3_bucket_name" {
  description = "S3 Bucket name for storing logs and AI models"
  type        = string
  default     = "blockchain-ai-logs"
}

# -------------------------------
# General Environment Variables
# -------------------------------
variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)"
  type        = string
  default     = "prod"
}

# ---------------------
# Network Configuration
# ---------------------
variable "vpc_id" {
  description = "VPC ID where the RDS instance will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of private subnet IDs for the RDS instance"
  type        = list(string)
}
