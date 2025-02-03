
# VPC for Blockchain Infrastructure
resource "aws_vpc" "blockchain_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "blockchain-vpc"
  }
}

# Public Subnet (For Blockchain Nodes)
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.blockchain_vpc.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = var.map_public_ip
  availability_zone       = var.availability_zone

  tags = {
    Name = "public-blockchain-subnet"
  }
}

# Private Subnet (For Security/AI Services)
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.blockchain_vpc.id
  cidr_block              = var.private_subnet_cidr
  map_public_ip_on_launch = false
  availability_zone       = var.availability_zone

  tags = {
    Name = "private-ai-security-subnet"
  }
}

# Internet Gateway for Public Nodes
resource "aws_internet_gateway" "blockchain_igw" {
  vpc_id = aws_vpc.blockchain_vpc.id

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

resource "aws_eks_node_group" "blockchain_worker_nodes" {
  cluster_name    = var.cluster_name # Change from aws_eks_cluster.blockchain_eks.name
  node_group_name = "blockchain-node-group"
  node_role_arn   = var.eks_role_arn
  subnet_ids      = var.subnet_ids
  instance_types  = [var.eks_instance_type]

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 1
  }

  tags = {
    Name = "blockchain-node-group"
  }
}
