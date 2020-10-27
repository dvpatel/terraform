variable "ssh_key_name" {
  description = "Bastion SSH Key"
  type        = string
  default     = "WebserverSGKeyPair"
}

variable "instance_profile" {
  description = "EC2 Instance Profile"
  type        = string
  default     = "WebServerSGRole"
}

variable "vpc_id" {
  description = "VPC Id"
  type        = string
}

variable "vpc_public_subnet_id" {
  description = "VPC Public Subnet ID"
  type        = string
}

variable "ingress_cidr_block" {
  description = "Ingress cidr block"
  type        = list(string)
  default     = ["24.218.157.167/32"]
}

variable "user_data_file" {
  description = "Bastion User-Data"
  type        = string
  default     = "user-data.sh"
}
