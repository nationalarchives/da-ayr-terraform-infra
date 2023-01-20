 #module "da-vpc" {
 #  source = "../../modules/da-vpc"
 #  vpc_cidr = var.vpc_cidr
 #  environment = var.environment
 #  enable_nat_gateway = var.enable_nat_gateway
 #  project_name = var.project_name
 #  aws_account_id = var.aws_account_id
 #  providers = {
 #    aws = aws
     # aws.us-east-1 = aws.us-east-1
 #    aws.eu-west-2 = aws.us-east-1
 #  }
 #}

 module "da-vpc" {
  source = "../../modules/da-vpc"
  vpc_cidr = var.vpc_cidr
  environment = var.environment
  enable_nat_gateway = var.enable_nat_gateway
  project_name = var.project_name
  aws_account_id = var.aws_account_id
  managment_id = var.managment_id
  image = var.image
  image_tag = var.image_tag
  app_port = var.app_port
  image_keycloak = var.image_keycloak
  image_tag_keycloak = var.image_tag_keycloak
  app_port_keycloak = var.app_port_keycloak
  fqdn = var.fqdn
  fqdn_keycloak = var.fqdn_keycloak
  providers= {
    aws=aws
    aws.us-east-1=aws.us-east-1
  }
}
 
# resource "aws_vpc" "test" {
#  cidr_block       = "10.0.0.0/16"
#  instance_tenancy = "default"
#
#  tags = {
#    Name = "ayr-testing-non-prod"
#  }
#}