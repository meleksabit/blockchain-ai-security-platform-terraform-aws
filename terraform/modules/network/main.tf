
# VPC for Blockchain Infrastructure
data "aws_vpc" "default" {
  default = true
}

resource "aws_vpc" "blockchain_vpc" {
  count                = length(data.aws_vpc.default.id) > 0 ? 0 : 1
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
}

# Public Subnet (For Blockchain Nodes)
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.blockchain_vpc[0].id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = var.map_public_ip
  availability_zone       = var.availability_zone

  tags = {
    Name = "public-blockchain-subnet"
  }
}

# Private Subnet (For Security/AI Services)
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.blockchain_vpc[0].id
  cidr_block              = var.private_subnet_cidr
  map_public_ip_on_launch = false
  availability_zone       = var.availability_zone

  tags = {
    Name = "private-ai-security-subnet"
  }
}

# Internet Gateway for Public Nodes
resource "aws_internet_gateway" "blockchain_igw" {
  vpc_id = aws_vpc.blockchain_vpc[0].id

  tags = {
    Name = "blockchain-internet-gateway"
  }
}

# Route Table for Public Subnet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.blockchain_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.blockchain_igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# Associate Route Table with Public Subnet
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Security Group for EKS Cluster
resource "aws_eks_node_group" "blockchain_worker_nodes" {
  cluster_name    = var.cluster_name # Change from aws_eks_cluster.blockchain_eks.name
  node_group_name = "blockchain-node-group"
  node_role_arn   = var.eks_role_arn
  subnet_ids      = var.subnet_ids
  instance_types  = [var.eks_instance_type]

  depends_on = [aws_db_subnet_group.blockchain_rds_subnet_group]

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 1
  }

  tags = {
    Name = "blockchain-node-group"
  }
}

# RDS Subnet Group for Blockchain Database
resource "aws_db_subnet_group" "blockchain_rds_subnet_group" {
  name       = "blockchain-rds-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "blockchain-rds-subnet-group"
  }
}
