variable "cluster_name" {
  description = "EKS Cluster name"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for EKS"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for EKS worker nodes"
  type        = list(string)
  default     = []
}

variable "eks_role_arn" {
  description = "IAM Role ARN for EKS Cluster"
  type        = string
  default     = "arn:aws:iam::123456789012:role/dummy-role"
}

variable "security_group" {
  description = "Security group for EKS worker nodes"
  type        = string
}

variable "eks_instance_type" {
  description = "EC2 instance type for EKS worker nodes"
  type        = string
  default     = "t3.micro"
}

variable "vpc_id" {
  description = "VPC ID where resources will be deployed"
  type        = string
}

variable "allowed_ssh_ip" {
  description = "List of CIDR blocks allowed for SSH access"
  type        = list(string)
}
