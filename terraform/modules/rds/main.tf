# ---------------------------------
# Create RDS PostgreSQL Instance
# ---------------------------------
resource "aws_db_instance" "blockchain_rds" {
  allocated_storage    = 20
  engine               = "postgres"
  engine_version       = "17.2"
  instance_class       = "db.t2.micro"
  identifier           = "blockchain-db"
  storage_encrypted    = true
  username             = local.db_creds["username"]
  password             = local.db_creds["password"]
  db_subnet_group_name = aws_db_subnet_group.blockchain_rds_subnet.name

  publicly_accessible       = false
  multi_az                  = true  # For High availability
  backup_retention_period   = 7     # Retain backups for 7 days
  skip_final_snapshot       = false # Create final snapshot when deleting
  final_snapshot_identifier = "blockchain-db-final"

  vpc_security_group_ids = [aws_security_group.rds_sg.id] # Restrict access to RDS SG only

  tags = {
    Name = "blockchain-postgres"
  }
}

# RDS Subnet Group
resource "aws_db_subnet_group" "blockchain_rds_subnet" {
  name       = "blockchain-rds-subnet-group"
  subnet_ids = var.rds_subnet_ids # Use the same private subnets

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
