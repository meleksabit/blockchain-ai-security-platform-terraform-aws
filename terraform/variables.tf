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
  description = "CIDR block for private subnet"
  default     = "10.0.2.0/25"
}

variable "availability_zone" {
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
  default     = "blockchain-cluster"
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

# -------------------------------
# RDS Database Configuration
# -------------------------------

variable "subnet_ids" {
  description = "List of private subnet IDs for RDS"
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
