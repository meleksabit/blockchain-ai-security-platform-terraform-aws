output "eks_cluster_id" {
  description = "EKS Cluster ID"
  value       = aws_eks_cluster.blockchain_eks.id
}

output "eks_cluster_endpoint" {
  description = "Endpoint for the Kubernetes API server"
  value       = aws_eks_cluster.blockchain_eks.endpoint
}

output "eks_cluster_arn" {
  description = "Amazon Resource Name (ARN) of the EKS Cluster"
  value       = aws_eks_cluster.blockchain_eks.arn
}

output "eks_cluster_security_group_id" {
  description = "Security Group ID for the EKS cluster"
  value       = aws_eks_cluster.blockchain_eks.vpc_config[0].cluster_security_group_id
}

output "eks_cluster_certificate_authority" {
  description = "EKS cluster certificate authority data"
  value       = aws_eks_cluster.blockchain_eks.certificate_authority[0].data
}

output "eks_oidc_issuer" {
  description = "OIDC Issuer URL for IAM authentication"
  value       = aws_eks_cluster.blockchain_eks.identity[0].oidc[0].issuer
}
