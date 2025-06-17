terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    infisical = {
      source  = "infisical/infisical"
      version = ">= 0.2.0"
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

provider "infisical" {
  token = var.infisical_token
}
