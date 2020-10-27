# Output variable definitions

output "vpc" {
  description = "VPC name"
  value       = module.vpc_for_eks.name
}

output "vpc_cidr" {
  description = "VPC Cidr"
  value       = [module.vpc_for_eks.vpc_cidr_block]
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc_for_eks.vpc_id
}

output "cluster_name" {
  description = "Cluster name"
  value       = var.cluster_name
}

output "private_subnet_ids" {
  description = "Privat Subnet Ids"
  value       = module.vpc_for_eks.private_subnets
}

output "private_subnets_eks" {
  description = "Privat Subnets"
  value       = module.vpc_for_eks.private_subnets
}

output "public_subnets_eks" {
  description = "Public Subnets"
  value       = module.vpc_for_eks.public_subnets
}

output "public_subnet_ids" {
  description = "Public Subnet IDs"
  value       = data.aws_subnet_ids.public
}
