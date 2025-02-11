# ---------------------------------
# Create EKS Cluster and Node Group
# ---------------------------------

# EKS Cluster
resource "aws_eks_cluster" "blockchain_eks" {
  name     = var.cluster_name
  role_arn = var.eks_role_arn

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.eks_api_sg.id] # Attach SG to EKS Cluster
  }

  tags = {
    Name = "blockchain-eks"
  }
}

# EKS Node Group
resource "aws_eks_node_group" "blockchain_worker_nodes" {
  cluster_name    = aws_eks_cluster.blockchain_eks.name
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
