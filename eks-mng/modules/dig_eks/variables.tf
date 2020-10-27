variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_name" {
  description = "VPC name"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "cluster_iam_role_name" {
  description = "EKS Cluster Role Name"
  type        = string
  default     = "devEKSClusterRole"
}

variable "nodegroup_role_name" {
  description = "EKS NodeGroup Role Name"
  type        = string
  default     = "devNodeInstanceRole"
}

variable "node_group_name" {
  description = "EKS NodeGroup Name"
  type        = string
  default     = "ng"
}

variable "node_instance_type" {
  description = "EKS Node Instance Type"
  type        = string
  default     = "t2.small"
}





variable "manage_cluster_iam_resources" {
  description = "EKS Manage IAM Resources"
  type        = bool
  default     = false
}

variable "manage_worker_iam_resources" {
  description = "EKS NodeGroup IAM Resources"
  type        = bool
  default     = false
}


variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap."
  type        = list(string)

  default = [
    "777777777777",
    "888888888888",
  ]
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))

  default = [
    {
      rolearn  = "arn:aws:iam::66666666666:role/role1"
      username = "role1"
      groups   = ["system:masters"]
    },
  ]
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = [
    {
      userarn  = "arn:aws:iam::66666666666:user/user1"
      username = "user1"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::66666666666:user/user2"
      username = "user2"
      groups   = ["system:masters"]
    },
  ]
}
