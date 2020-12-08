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

variable "spot_node_group_name_grp1" {
  description = "EKS Spot NodeGroup Name Group1"
  type        = string
  default     = "spot-ng-1x"
}

variable "spot_node_group_name_grp2" {
  description = "EKS Spot NodeGroup Name Group2"
  type        = string
  default     = "spot-ng-2x"
}

variable "spot_node_instance_types_grp1" {
  description = "EKS Node Instance Type for Spots Group 1"
  type        = list(string)
  default     = ["m5.xlarge", "m5n.xlarge", "m5d.xlarge", "m5dn.xlarge","m5a.xlarge", "m4.xlarge"] 
}

variable "spot_node_instance_types_grp2" {
  description = "EKS Node Instance Type for Spots Group 2"
  type        = list(string)
  default     = ["m5.2xlarge", "m5n.2xlarge", "m5d.2xlarge", "m5dn.2xlarge","m5a.2xlarge", "m4.2xlarge"]
}

variable "mng_node_group_name" {
  description = "EKS OnDemand NodeGroup Name"
  type        = string
  default     = "od-ng"
}

variable "mng_node_instance_types" {
  description = "EKS Node Instance Type for OnStances"
  type        = string
  default     = "t3.medium"
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
