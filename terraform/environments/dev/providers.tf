provider "aws" {
  region = "eu-west-2"
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

provider aws {
  alias = "nonprod"
  region = var.region
  assume_role {
    role_arn =  var.assume_role.nonprod
  }

 default_tags {
    tags = {
      nonprod = var.nonprod
      Owner = "Terraform"
      StateBucket = var.bucket
      StatePrefix = var.key
    }
  }
}


provider "aws" {
  alias = "us-east-1"
  region = "us-east-1"
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

  ## Backend should be configured with terraform init, eg:
  ##   `terraform init -backend-config=backend-config.auto.tfvars -reconfigure`
  ## This allows for keeping terraform code DRY between environments
  ## Automatically importing backend config values as variables allows for
  ## explicit tagging and later identifying the management of resources
  backend "s3" {
  }
}

