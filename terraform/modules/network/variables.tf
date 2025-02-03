variable "aws_region" {
  description = "AWS region for deployment"
  default     = "eu-central-1"
}

variable "aws_profile" {
  description = "AWS CLI profile to use for authentication"
  type        = string
  default     = "default"
}

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
  description = "Availability zone"
  default     = "eu-central-1a"
}

variable "map_public_ip" {
  description = "Assign public IP to instances in the public subnet"
  default     = true
}

variable "allowed_ssh_ip" {
  description = "Allowed IP for SSH access to EC2 instances"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "eks_role_arn" {
  description = "IAM role ARN for EKS nodes"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for EKS worker nodes"
  type        = list(string)
}

variable "eks_instance_type" {
  description = "EC2 instance type for EKS worker nodes"
  type        = string
}
