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
