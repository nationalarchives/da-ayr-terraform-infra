variable "bucket" {
  description = "Backend bucket name"
}

variable "key" {
  description = "Backend key"
}

variable "region" {
  description = "Backend AWS region"
}

variable "encrypt" {
  description = "Backend encryption setting"
}

variable "acl" {
  description = "State bucket acl"
}

variable "dynamodb_table" {
  description = "State dynamodb"
}

variable "prefix" {
  description = "Prefix for transformation engine resources"
  type        = string
}

variable "da_ayr_repositories" {
  description = "List AYR repositories that require access to AYR AWS Accounts"
  type        = list(string)
}

variable "terraform_roles" {
  description = "Terraform roles that can be assumed by da_ayr_github_actions_open_id_connect role"
  type        = list(string)
}

variable "assume_role" {
  description = "The role to be assumed by terraform"
  type = object({
    management = string
    nonprod    = string
  })
}

variable "role_arn" {
  description = "The ARN role"
  type        = string
}

variable "account_id" {
  description = "Account ID"
  type        = string
}

variable "managment_id" {
  description = "Managment Account ID"
  type        = string
}

variable "environment" {
  description = "Enviromenet"
  type        = string
}

variable "nonprod_id" {
  description = "AWS non prod id"
  type        = string
}
