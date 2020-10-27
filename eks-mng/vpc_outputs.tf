output "private_subnet_ids" {
  description = "VPC Private Subnet Ids"
  value       = module.vpc_eks.private_subnet_ids
}
