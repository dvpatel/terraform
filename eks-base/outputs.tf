output "bastion_ip" {
  description = "Bastion Public IP"
  value       = module.app_bastion[0].bastion_ip[0]
}

output "bastion_dns" {
  description = "Public DNS name assigned to the EC2 instance"
  value       = module.app_bastion[0].bastion_dns[0]
}
