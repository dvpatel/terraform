variable "profile" {
  description = "aws profile for bastion creation"
  default = "default"
}

variable "region" {
  description = "bastion region"
  default = "us-east-1"
}

variable "public_vpc" {
  description = "Public VPC Id"
  default = "vpc-b1a465d6"
}

variable "cluster_name" {
  description = "EKS Cluster Name"
  default = "dev-eks"
}

variable "nodegroup_name" {
  description = "EKS NodeGroup Name"
  default = "dev-mng"
}

variable "manage_cluster_iam_resources" {
  description = "EKS Manage IAM Resources"
  default = false
}

variable "cluster_iam_role_name" {
  description = "EKS Cluster Role Name"
  default = "devEKSClusterRole"
}

variable "manage_worker_iam_resources" {
  description = "EKS NodeGroup IAM Resources"
  default = "false"
}

variable "nodegroup_role_name" {
  description = "EKS NodeGroup Role Name"
  default = "devNodeInstanceRole"
}

variable "bastion_instance_profile" {
  description = "EC2 instance profile for Bastion Host"
  default = "WebServerSGRole"
}

variable "bastion_ssh_key" {
  description = "EC2 instance ssh key"
  default = "WebserverSGKeyPair"
}

variable "bastion_ami_id" {
  description = "bastion ami"
  default = "ami-0947d2ba12ee1ff75"
}

variable "bastion_instance_type" {
  #  Free tier instance;
  description = "bastion instance type"
  default = "t2.micro"
}

variable "bastion_subnet" {
  description = "bastion public subnet"
  default = "subnet-82d8b3a8"
}

variable "bastion_user_data" {
  description = "bastion user data script"
  default = "user-data.sh"
}

variable "bastion_sg" {
  description = "bastion sg"
  default = "sg-06472963792f3a2b3"
}
