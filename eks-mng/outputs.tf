output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.app_eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane."
  value       = module.app_eks.cluster_security_group_id
}

output "region" {
  description = "AWS region."
  value       = var.region
}

output "cluster_name" {
  description = "AWS EKS cluster."
  value       = var.cluster_name
}

output "node_groups" {
  description = "Outputs from node groups"
  value       = module.app_eks.node_groups
}
