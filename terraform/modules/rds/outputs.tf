output "rds_endpoint" {
  value = aws_db_instance.blockchain_rds.endpoint
}

output "rds_db_username" {
  value       = local.db_creds["username"]
  description = "Database username retrieved from Secrets Manager"
}

output "rds_security_group_id" {
  value = aws_security_group.rds_sg.id
}
