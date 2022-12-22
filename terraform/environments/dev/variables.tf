####################
# Environment Config
####################
variable "environment" {
  type = string
  description = "Name of the environment being managed"
}

variable "project_name" {
  description = "Project Name"
  type = string
}
variable "aws_account_id" {
  description = "Aws acc id"
  type = string
}

##################
# Application VPC
##################
variable "vpc_cidr" {
  description = "The CIDR block for the application VPC"
  type        = string
}

variable "enable_nat_gateway" {
  type        = bool
  default     = false
  description = "NAT GATEWAY ON / OFF"
}

variable "enable_vpn_gateway" {
  type        = bool
  default     = false
  description = "VPN GATEWAY ON / OFF"
}

#################
# Backend config
#################
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