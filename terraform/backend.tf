# To use a remote S3 backend, follow these steps:
# 1. Run `terraform init` without the backend block.
# 2. Create the S3 bucket for your state file manually or via another TF module.
# 3. Uncomment the block below and run `terraform init -migrate-state`.

# terraform {
#   backend "s3" {
#     bucket         = "your-terraform-state-bucket"
#     key            = "portfolio-site/terraform.tfstate"
#     region         = "ap-south-1"
#     encrypt        = true
#     dynamodb_table = "terraform-lock-table"
#   }
# }
