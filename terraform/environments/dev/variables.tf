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

#################
# ECS Task Config
#################
variable "image" {
  type = string
  description = "location and name of the container image for the ECS task"
}

variable "image_tag" {
  type = string
  description = "The tag (e.g. version or 'latest') to retrieve for this environment"
}

variable "app_port" {
  type = number
  description = "The port the application will listen on within its container"
  default = 8000
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

variable "assume_role" {
  description = "The role to be assumed by terraform"
  type        = object({
    management = string
    nonprod    = string
  })
}