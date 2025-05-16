# ----------------------------------------------------------------------------
# This file is used to configure the provider for the Terraform configuration.
# ----------------------------------------------------------------------------
provider "aws" {
  region = var.aws_region # AWS region

  assume_role {
    role_arn = var.aws_role_arn
  }
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
}
