# --------------------------------------------
# Create security groups for EKS nodes and RDS
# --------------------------------------------

# Security Group for API Services (EKS Nodes, Lambda, EC2)
resource "aws_security_group" "eks_api_sg" {
  vpc_id = aws_vpc.blockchain_vpc[0].id
  name   = "eks-api-security-group"

  # Allow EKS nodes to talk to RDS (PostgreSQL)
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [data.aws_security_group.rds_sg.id] # Restrict access to RDS SG
  }

  # Allow only your IP to SSH (if needed)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_ip # ✅ Only your IP
  }

  # Allow outbound traffic (EKS nodes need this for API calls)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-api-security-group"
  }
}

# Lookup the RDS SG after it's created
data "aws_security_group" "rds_sg" {
  filter {
    name   = "group-name"
    values = ["rds-sg"]
  }
}

# Security Group for EKS worker nodes
resource "aws_security_group" "eks_nodes_sg" {
  name        = "eks-nodes-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = aws_vpc.blockchain_vpc[0].id

  tags = {
    Name = "eks-nodes-sg"
  }
}

# Allow inbound SSH traffic (Port 22)
resource "aws_security_group_rule" "allow_node_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.allowed_ssh_ip] # Allow SSH from your IP
  security_group_id = aws_security_group.eks_nodes_sg.id
}

# Allow inbound Ethereum P2P traffic (Port 30303)
resource "aws_security_group_rule" "ethereum_p2p" {
  type              = "ingress"
  from_port         = 30303
  to_port           = 30303
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] # You can restrict to known nodes
  security_group_id = aws_security_group.eks_nodes_sg.id
}

# Allow inbound Bitcoin P2P traffic (Port 8333)
resource "aws_security_group_rule" "bitcoin_p2p" {
  type              = "ingress"
  from_port         = 8333
  to_port           = 8333
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] # You can restrict to known nodes
  security_group_id = aws_security_group.eks_nodes_sg.id
}

# Allow all outbound traffic (default)
resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks_nodes_sg.id
}

# Security Group for RDS PostgreSQL
resource "aws_security_group" "rds_sg" {
  vpc_id      = aws_vpc.blockchain_vpc[0].id
  name        = "rds-security-group"
  description = "Security group for RDS PostgreSQL"

  # Allow only EKS API services to access RDS
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [data.aws_security_group.eks_api_sg.id] # Only EKS API SG can connect
  }

  tags = {
    Name = "rds-security-group"
  }
}

# Lookup the EKS API SG after it's created
data "aws_security_group" "eks_api_sg" {
  filter {
    name   = "group-name"
    values = ["eks-api-sg"]
  }
}
