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

module "da_ayr_github_actions_open_id_connect" {
  source = "../../modules/open-id-connect"
  prefix = var.prefix
  da_ayr_repositories = var.da_ayr_repositories
  terraform_roles = var.terraform_roles
  account_id                                  = var.managment_id
}

#module "da_ayr_nonprod_terraform_roles" {
 # source                                  = "../../modules/terraform-roles"
  #external_id                             = var.external_id
  #roles_can_assume_terraform_role         = module.ayr_github_actions_open_id_connect.da_ayr_open_id_connect_roles.nonprod
  #prefix                                  = var.prefix
  #permission_boundary_policy_path         = "./templates/permission-boundary-policy/environments.tftpl"
  #terraform_policy_path                   = "./templates/terraform-role-policy/environments.tftpl"
  #providers = {
 #   aws = aws.nonprod
 # }
 # terraform_iam_policy_path    = "./templates/terraform-iam-policy/environments.tftpl"
 # da_ayr_terraform_backend_policy = data.aws_iam_policy_document.da_ayr_terraform_backend.json
 # account_id                   = data.aws_caller_identity.nonprod.account_id
#}