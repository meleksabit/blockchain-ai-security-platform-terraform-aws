# ------------------------------------------------  
# This is the main file that calls the modules
# The modules are defined in the modules directory
# ------------------------------------------------

# Fetch the existing VPC dynamically (if available)
data "aws_vpc" "existing" {
  filter {
    name   = "tag:Name"
    values = ["my-custom-vpc"] # Replace with your VPC name
  }
}

# Decide which VPC ID to use: existing or newly created
locals {
  vpc_id = try(data.aws_vpc.existing.id, module.network.vpc_id)
}

module "network" {
  source              = "./modules/network"
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  availability_zones  = var.availability_zones
  map_public_ip       = var.map_public_ip
  allowed_ssh_ip      = var.allowed_ssh_ip
  aws_region          = var.aws_region
  aws_profile         = var.aws_profile
  vpc_id              = local.vpc_id
  cluster_name        = var.cluster_name
  eks_role_arn        = module.iam.eks_role_arn
  eks_instance_type   = var.eks_instance_type
  eks_subnet_ids      = module.network.private_subnet_ids
  rds_subnet_ids      = module.network.private_subnet_ids
  subnet_ids          = module.network.subnet_ids
}

module "eks" {
  source            = "./modules/eks"
  cluster_name      = var.cluster_name
  cluster_version   = var.cluster_version
  subnet_ids        = module.network.private_subnet_ids
  security_group    = module.network.eks_nodes_sg_id
  eks_role_arn      = module.iam.eks_role_arn
  eks_instance_type = var.eks_instance_type
  vpc_id            = local.vpc_id
}

module "rds" {
  source                = "./modules/rds"
  vpc_id                = local.vpc_id
  rds_security_group_id = module.network.rds_security_group_id
  rds_subnet_ids        = module.network.private_subnet_ids
  rds_role_arn          = module.iam.rds_role_arn
  db_username           = var.db_username
  db_password           = var.db_password
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
