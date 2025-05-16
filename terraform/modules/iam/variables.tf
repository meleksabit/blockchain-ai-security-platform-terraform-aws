variable "eks_cluster_name" {
  description = "EKS cluster name for IAM role"
  type        = string
}

variable "eks_role_name" {
  description = "The name of the IAM role for the EKS cluster"
  type        = string
  default     = "eks-cluster-role"
}

variable "node_group_role_name" {
  description = "The IAM role name for EKS worker nodes"
  type        = string
  default     = "eks-node-group-role"
}

variable "ssm_role_name" {
  description = "IAM role name for Systems Manager (SSM) access"
  type        = string
  default     = "ssm-role"
}
