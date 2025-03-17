# ------------------------------------------------  
# This is the main file that calls the modules
# ------------------------------------------------

resource "aws_vpc" "blockchain_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "blockchain-vpc"
  }
}

module "network" {
  source              = "./modules/network"
  vpc_id              = var.vpc_id
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  availability_zones  = var.availability_zones
  map_public_ip       = var.map_public_ip
  allowed_ssh_ip      = var.allowed_ssh_ip
  aws_region          = var.aws_region
  subnet_ids          = module.network.subnet_ids
  rds_subnet_ids      = module.network.private_subnet_ids
  eks_role_arn        = var.eks_role_arn
  eks_subnet_ids      = var.eks_subnet_ids
  cluster_name        = var.cluster_name
  eks_instance_type   = var.eks_instance_type
}

module "eks" {
  source            = "./modules/eks"
  cluster_name      = var.cluster_name
  cluster_version   = var.cluster_version
  subnet_ids        = module.network.private_subnet_ids
  security_group    = module.eks.eks_api_security_group_id
  eks_role_arn      = module.iam.eks_role_arn
  eks_instance_type = var.eks_instance_type
  vpc_id            = module.network.vpc_id
  allowed_ssh_ip    = var.allowed_ssh_ip
}

module "rds" {
  source                = "./modules/rds"
  vpc_id                = var.vpc_id
  rds_security_group_id = module.network.rds_security_group_id
  rds_subnet_ids        = module.network.private_subnet_ids
  rds_db_username       = var.rds_db_username
  rds_db_password       = var.rds_db_password
  rds_role_arn          = module.iam.rds_role_arn
  eks_nodes_sg_id       = module.network.eks_nodes_sg_id
}

module "iam" {
  source           = "./modules/iam"
  eks_cluster_name = var.cluster_name
}

module "s3" {
  source         = "./modules/s3"
  project_suffix = var.project_suffix
  environment    = var.environment
  s3_role_arn    = module.iam.s3_role_arn
}

module "vault" {
  source         = "./modules/vault"
  infura_api_key = var.infura_api_key
}
