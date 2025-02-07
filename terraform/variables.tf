# ------------------------------------------------------------
# Define all the variables used in the Terraform configuration
# ------------------------------------------------------------

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "eu-central-1"
}

variable "aws_profile" {
  description = "AWS CLI profile to use for authentication"
  type        = string
  default     = "default"
}

# ---------------------
# Network Configuration
# ---------------------

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  default     = "10.0.0.0/24"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  default     = "10.0.1.0/25"
}

variable "private_subnet_cidr" {
  description = "CIDR blocks for private subnet"
  type        = list(string)
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "Availability Zone"
  default     = "eu-central-1a"
}

variable "map_public_ip" {
  description = "Assign public IP to instances in the public subnet"
  default     = true
}

variable "allowed_ssh_ip" {
  description = "Allowed SSH IP range"
  type        = string
  sensitive   = true
}

# -------------------------
# EKS Cluster Configuration
# -------------------------
variable "cluster_name" {
  description = "EKS Cluster Name"
  type        = string
  default     = "blockchain-cluster"
}

variable "eks_role_arn" {
  description = "IAM Role ARN for EKS Cluster"
  type        = string
}

variable "cluster_version" {
  description = "EKS Cluster Version"
  default     = "1.32"
}

variable "eks_instance_type" {
  description = "EC2 instance type for EKS worker nodes"
  type        = string
  default     = "t3.micro"
}

variable "eks_subnet_ids" {
  description = "List of private subnets for EKS"
  type        = list(string)
}

# -------------------------------
# RDS Database Configuration
# -------------------------------

variable "rds_subnet_ids" {
  description = "List of private subnets for RDS"
  type        = list(string)
}
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

variable "eks_nodes_sg_id" {
  description = "Security group ID for EKS worker nodes"
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

variable "project_suffix" {
  description = "Suffix to make bucket names unique"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  default     = "prod"
}
