# Output variable definitions

output "public_ip" {
  description = "Bastion IP"
  value       = module.bastion_instance.public_ip
}
