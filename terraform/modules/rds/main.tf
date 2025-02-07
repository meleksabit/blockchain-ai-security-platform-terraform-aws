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

  vpc_security_group_ids = [var.rds_security_group_id]
  db_subnet_group_name   = aws_db_subnet_group.blockchain_rds_subnet_group.name
  monitoring_role_arn    = aws_iam_role.rds_role.arn

  tags = {
    Name        = "blockchain-rds"
    Environment = var.environment
  }
}

resource "aws_db_subnet_group" "blockchain_rds_subnet_group" {
  name       = "blockchain-rds-subnet-group"
  subnet_ids = var.rds_subnet_ids

  tags = {
    Name = "blockchain-rds-subnet-group"
  }
}

resource "aws_iam_role" "rds_role" {
  name = "rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "monitoring.rds.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}
