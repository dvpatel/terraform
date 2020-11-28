# Output variable definitions

output "bastion_ip" {
  description = "Bastion IP"
  value       = module.bastion_instance.public_ip
}

output "bastion_dns" {
  description = "Public DNS name assigned to the EC2 instance"
  value       = module.bastion_instance.public_dns
}
