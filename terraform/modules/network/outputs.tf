output "subnet_ids" {
  description = "List of subnet IDs"
  value       = concat([aws_subnet.public_subnet.id], aws_subnet.private_subnet[*].id)
}

output "public_subnet_ids" {
  value = [aws_subnet.public_subnet.id]
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private_subnet[*].id
}

output "eks_nodes_sg_id" {
  description = "Security group ID for EKS nodes"
  value       = aws_security_group.eks_nodes_sg.id
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.blockchain_vpc[0].id
}

output "cidr_blocks" {
  description = "The IP address allowed to SSH to the EC2 instances"
  value       = var.allowed_ssh_ip
  sensitive   = true
}

output "rds_security_group_id" {
  description = "RDS Security Group ID"
  value       = aws_security_group.rds_sg.id
}

output "rds_subnet_ids" {
  value = aws_subnet.rds_subnets[*].id
}
