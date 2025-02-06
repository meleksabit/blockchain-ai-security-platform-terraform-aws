# -----------------------------------------------
# Lock Terraform version and AWS provider version
# -----------------------------------------------
terraform {
  required_version = ">= 1.5.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Lock AWS provider version
    }
  }
}
