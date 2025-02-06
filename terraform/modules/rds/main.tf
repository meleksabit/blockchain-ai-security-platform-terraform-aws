# --------------------
# Create RDS instance
# --------------------

# Create RDS instance
resource "aws_db_instance" "blockchain_rds" {
  identifier        = "blockchain-db"
  engine            = "postgres"
  engine_version    = "17.2"
  instance_class    = "db.t2.micro"
  allocated_storage = 20
  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  publicly_accessible       = false
  multi_az                  = true  # For High availability
  backup_retention_period   = 7     # Retain backups for 7 days
  skip_final_snapshot       = false # Create final snapshot when deleting
  final_snapshot_identifier = "blockchain-db-final"

  vpc_security_group_ids = [module.network.rds_security_group_id]
  db_subnet_group_name   = aws_db_subnet_group.blockchain_rds_subnet_group.name
  monitoring_role_arn    = aws_iam_role.rds_role.arn

  tags = {
    Name        = "blockchain-rds"
    Environment = var.environment
  }
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "RDS Subnet Group"
  }
}
