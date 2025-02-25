# --------------------------------------------
# Create security groups for EKS nodes and RDS
# --------------------------------------------

# Security Group for API Services (EKS Nodes, Lambda, EC2)
resource "aws_security_group" "eks_api_sg" {
  vpc_id = try(aws_vpc.blockchain_vpc[0].id, "")
  name   = "eks-api-security-group"


  # Allow only your IP to SSH (if needed)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_ip
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

# Security Group for EKS worker nodes
resource "aws_security_group" "eks_nodes_sg" {
  name        = "eks-nodes-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = try(aws_vpc.blockchain_vpc[0].id, "")

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
  cidr_blocks       = var.allowed_ssh_ip # Allow SSH from your IP
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
  vpc_id      = try(aws_vpc.blockchain_vpc[0].id, "")
  name        = "rds-security-group"
  description = "Security group for RDS PostgreSQL"

  tags = {
    Name = "rds-security-group"
  }
}

# Allow EKS API SG to access RDS SG (Port 5432)
resource "aws_security_group_rule" "eks_to_rds" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_api_sg.id
  security_group_id        = aws_security_group.rds_sg.id
}

# Allow RDS SG to access EKS API SG (Port 443)
resource "aws_security_group_rule" "rds_to_eks" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.rds_sg.id
  security_group_id        = aws_security_group.eks_api_sg.id
}
