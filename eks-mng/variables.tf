variable "region" {
  default = "us-east-1"
}

variable "profile" {
  description = "aws profile for bastion creation"
  default     = "default"
}

variable "vpc_name" {
  description = "VPC name"
  default     = "dev-vpc"
}

variable "cluster_name" {
  description = "EKS cluster name"
  default     = "dev-eks"
}
