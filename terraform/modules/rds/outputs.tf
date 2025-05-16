output "rds_endpoint" {
  value = aws_db_instance.blockchain_rds.endpoint
}

output "db_name" {
  value = aws_db_instance.blockchain_rds.identifier
}

output "rds_db_username" {
  value = aws_db_instance.blockchain_rds.username
}

output "rds_security_group_id" {
  value = aws_security_group.rds_sg.id
}
