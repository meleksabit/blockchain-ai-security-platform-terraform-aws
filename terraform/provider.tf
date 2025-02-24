# ----------------------------------------------------------------------------
# This file is used to configure the provider for the Terraform configuration.
# ----------------------------------------------------------------------------
provider "aws" {
  region = var.aws_region # AWS region

  assume_role {
    role_arn = var.aws_role_arn
  }
}
