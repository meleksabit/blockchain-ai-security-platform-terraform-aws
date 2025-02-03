module "network" {
  source              = "./modules/network"
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  availability_zone   = var.availability_zone
  map_public_ip       = var.map_public_ip
  allowed_ssh_ip      = var.allowed_ssh_ip
  aws_region          = var.aws_region
  aws_profile         = var.aws_profile
  cluster_name        = var.cluster_name
  eks_role_arn        = module.iam.eks_role_arn
  subnet_ids          = module.network.subnet_ids
  eks_instance_type   = var.eks_instance_type
}

module "eks" {
  source            = "./modules/eks"
  cluster_name      = var.cluster_name
  cluster_version   = var.cluster_version
  subnet_ids        = module.network.subnet_ids
  security_group    = module.network.eks_nodes_sg_id
  eks_role_arn      = module.iam.eks_role_arn
  eks_instance_type = var.eks_instance_type
}

module "iam" {
  source           = "./modules/iam"
  eks_cluster_name = var.cluster_name
}
