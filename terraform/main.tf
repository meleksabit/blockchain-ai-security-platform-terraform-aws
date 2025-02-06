# ------------------------------------------------  
# This is the main file that calls the modules
# The modules are defined in the modules directory
# ------------------------------------------------

# Fetch the existing VPC dynamically (if available)
data "aws_vpc" "existing" {
  default = true
}

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
  vpc_id              = module.network.vpc_id # Uses default VPC if exists, otherwise creates a new one
}

# Decide which VPC ID to use: existing or newly created
locals {
  vpc_id = data.aws_vpc.existing.id != "" ? data.aws_vpc.existing.id : module.network.vpc_id
}

module "eks" {
  source            = "./modules/eks"
  cluster_name      = var.cluster_name
  cluster_version   = var.cluster_version
  subnet_ids        = module.network.subnet_ids
  security_group    = module.network.eks_nodes_sg_id
  eks_role_arn      = module.iam.eks_role_arn
  eks_instance_type = var.eks_instance_type
  vpc_id            = local.vpc_id
}

module "iam" {
  source           = "./modules/iam"
  eks_cluster_name = var.cluster_name
}

module "rds" {
  source                = "./modules/rds"
  vpc_id                = local.vpc_id
  rds_security_group_id = module.network.rds_security_group_id
  subnet_ids            = module.network.private_subnets
  db_username           = var.db_username
  db_password           = var.db_password
}
