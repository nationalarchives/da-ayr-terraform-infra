module "da_ayr_github_actions_open_id_connect" {
  source               ="../../modules/open-id-connect"
  prefix               = var.prefix
  da_ayr_repositories  = var.da_ayr_repositories
  terraform_roles      = var.terraform_roles
  account_id           = var.managment_id
}
