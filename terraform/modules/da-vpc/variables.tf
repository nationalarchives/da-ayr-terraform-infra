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

variable "managment_id" {
  description = "Aws acc id"
  type = string
}

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

variable "app_vpc_dhcp_options_domain_name_servers" {
  description = "DNS Servers to use in application VPC, default to AWS provided"
  type        = list
  default     = ["AmazonProvidedDNS"]
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
variable "fqdn" {
  type = string
  description = "The fully-qualified domain name to use for the frontend"
}

#################
# ECS Task Config
#################
variable "image_keycloak" {
  type = string
  description = "location and name of the container image for the ECS task"
}

variable "image_tag_keycloak" {
  type = string
  description = "The tag (e.g. version or 'latest') to retrieve for this environment"
}

variable "app_port_keycloak" {
  type = number
  description = "The port the application will listen on within its container"
  default = 8080
}

variable "fqdn_keycloak" {
  type = string
  description = "The fully-qualified domain name to use for the frontend"
}
