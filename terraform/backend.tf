# -------------------------------------------------------------
# Define the backend configuration for the Terraform state file
# -------------------------------------------------------------
# terraform {
#   backend "s3" {
#     bucket         = "terraform-state-bucket-angel3"     # Bucket name
#     key            = "terraform/state/terraform.tfstate" # Path to the state file
#     region         = "eu-central-1"                      # Default AWS region 
#     encrypt        = true                                # Enable encryption
#     dynamodb_table = "terraform-lock-table"              # DynamoDB table name
#   }
# }

terraform {
  cloud {
    organization = "my-project-ai-powered"

    workspaces {
      name = "blockchain-ai-security-platform-terraform-aws"
    }
  }
}
