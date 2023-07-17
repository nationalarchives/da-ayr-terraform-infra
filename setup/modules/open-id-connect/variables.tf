
variable "prefix" {
  description = "Prefix for transformation engine resources"
  type        = string
}

variable "da_ayr_repositories" {
  description = "List AYR repositories that require access to AYR AWS Accounts"
  type        = list(string)
}


variable "account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "terraform_roles" {
  description = "Terraform roles that can be assumed by da_ayr_github_actions_open_id_connect role"
  type        = list(string)
}
