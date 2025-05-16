# Networking Outputs
output "vpc_id" {
  value       = module.network.vpc_id
  description = "ID of the created VPC"
}

output "public_subnets" {
  value       = module.network.public_subnet_ids
  description = "List of public subnet IDs"
}

output "private_subnets" {
  value       = module.network.private_subnet_ids
  description = "List of private subnet IDs"
}

# EKS Outputs
output "eks_cluster_id" {
  value       = module.eks.cluster_name
  description = "EKS Cluster ID"
}

output "eks_cluster_endpoint" {
  value       = module.eks.eks_cluster_endpoint
  description = "EKS Cluster API Endpoint"
}

output "eks_cluster_security_group" {
  value       = module.network.eks_nodes_sg_id
  description = "Security Group ID for EKS nodes"
}

# IAM Outputs
output "eks_role_arn" {
  value       = module.iam.eks_role_arn
  description = "IAM Role ARN for EKS Cluster"
}

output "rds_role_arn" {
  value       = module.iam.rds_role_arn
  description = "IAM Role ARN for RDS"
}

output "s3_role_arn" {
  value       = module.iam.s3_role_arn
  description = "IAM Role ARN for S3"
}

# RDS Outputs
output "rds_endpoint" {
  value       = module.rds.rds_endpoint
  description = "RDS database endpoint"
}

output "rds_db_username" {
  value       = module.rds.rds_db_username
  description = "RDS database username retrieved from AWS Secrets Manager"
  sensitive   = true
}

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "ecr_repository_urls" {
  value = module.ecr.repository_urls
}
