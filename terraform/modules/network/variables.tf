# ------------------------------------------------------------
# This file contains the variables used in the network module.
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

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/24"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.1.0/25"
}

variable "private_subnet_cidr" {
  description = "CIDR block for private subnet"
  type        = list(string)
}

variable "availability_zones" {
  description = "Availability zone"
  type        = list(string)
}

variable "map_public_ip" {
  description = "Assign public IP to instances in the public subnet"
  type        = bool
  default     = true
}

variable "allowed_ssh_ip" {
  description = "Allowed IP for SSH access to EC2 instances"
  type        = list(string)
  sensitive   = true
}

# -------------------------------
# General Environment Variables
# -------------------------------
variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "rds_subnet_ids" {
  description = "Subnet IDs for RDS"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID to associate with subnets and security groups"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for networking resources"
  type        = list(string)
}
