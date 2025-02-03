resource "aws_security_group" "eks_nodes_sg" {
  name        = "eks-nodes-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = aws_vpc.blockchain_vpc.id

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
