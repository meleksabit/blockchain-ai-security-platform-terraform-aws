output "subnet_ids" {
  description = "List of subnet IDs for EKS"
  value       = module.network.subnet_ids
}

output "eks_nodes_sg_id" {
  description = "Security group ID for EKS nodes"
  value       = module.network.eks_nodes_sg_id
}

output "eks_role_arn" {
  description = "IAM Role ARN for EKS"
  value       = module.iam.eks_role_arn
}

output "allow_node_ssh" {
  description = "The IP address allowed to SSH to the EC2 instances"
  value       = var.allowed_ssh_ip
  sensitive   = true
}
