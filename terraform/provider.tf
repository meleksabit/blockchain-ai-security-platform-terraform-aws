# ----------------------------------------------------------------------------
# This file is used to configure the provider for the Terraform configuration.
# ----------------------------------------------------------------------------
provider "aws" {
  region  = var.aws_region  # AWS region
  profile = var.aws_profile # AWS CLI profile
}
