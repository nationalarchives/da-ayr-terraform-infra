output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = module.vpc.vpc_arn
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "vpc_private_subnets" {
  description = "The IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "vpc_public_subnets" {
  description = "The IDs of private subnets"
  value       = module.vpc.public_subnets
}

output "default_security_group_id" {
  description = "The ID of the security group created by default on VPC creation"
  value       = module.vpc.default_security_group_id
}

output "default_network_acl_id" {
  description = "The ID of the default network ACL"
  value       = module.vpc.default_network_acl_id
}

output "default_route_table_id" {
  description = "The ID of the default route table"
  value       = module.vpc.default_route_table_id
}

output "nat_addresses" {
  description = "Outbound IP addresses from NAT gateways"
  value       = module.vpc.nat_public_ips
}

output "da-ayr_nhsbsa_net" {
  description = "Outbound IP addresses from NAT gateways"
  value       = module.vpc.nat_public_ips
}
# output "lambda_auth_arn" {
#   value = data.aws_lambda_function.lambda_auth_data.arn
# }

#
