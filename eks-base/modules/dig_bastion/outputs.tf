# Output variable definitions

output "public_ip" {
  description = "Bastion IP"
  value       = module.bastion_instance.public_ip
}

output "instance_public_dns" {
  description = "Public DNS name assigned to the EC2 instance"
  value       = module.bastion_instance.public_dns[0]
}
