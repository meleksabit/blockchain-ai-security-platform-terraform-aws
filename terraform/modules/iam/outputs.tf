output "eks_role_arn" {
  description = "IAM role ARN for EKS worker nodes"
  value       = aws_iam_role.node_group_role.arn
}

output "node_group_role_arn" {
  value = aws_iam_role.node_group_role.arn
}

output "ssm_role_arn" {
  value = aws_iam_role.ssm_role.arn
}

output "rds_role_arn" {
  description = "IAM Role ARN for RDS"
  value       = aws_iam_role.rds_role.arn
}

output "s3_role_arn" {
  value = aws_iam_role.s3_role.arn
}
