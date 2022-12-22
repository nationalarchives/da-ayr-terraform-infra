module "da-vpc" {
  source = "../../modules/da-vpc"
  vpc_cidr = var.vpc_cidr
  environment = var.environment
  enable_nat_gateway = var.enable_nat_gateway
  project_name = var.project_name
  aws_account_id = var.aws_account_id
  providers = {
    aws = aws
    # aws.us-east-1 = aws.us-east-1
    aws.eu-west-2 = aws.us-east-1
  }
}
