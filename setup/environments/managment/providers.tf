provider "aws" {
  region = var.region
  assume_role {
    role_arn =  var.assume_role.management
  }

  default_tags {
    tags = {
      Environment = var.environment
      Owner = "Terraform"
      StateBucket = var.bucket
      StatePrefix = var.key
    }
  }
}

terraform {
  ## Fix version of the providers to avoid breaking changes causing problems
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
  }
}

