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
