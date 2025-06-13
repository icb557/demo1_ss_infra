# resource "aws_s3_bucket" "terraform_state_bucket" {
#   bucket = "terraform-state-bucket-ss"
# }

# resource "aws_s3_bucket_versioning" "versioning_terraform_state_bucket" {
#   bucket = aws_s3_bucket.terraform_state_bucket.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket       = "terraform-state-bucket-ss"
    key          = "terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region                   = "us-east-1"
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "cursor"
}
