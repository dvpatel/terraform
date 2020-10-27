data "aws_eks_cluster" "cluster" {
  name = module.private_eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.private_eks.cluster_id
}

data "aws_availability_zones" "available" {
}

module "private_eks" {
  source = "terraform-aws-modules/eks/aws"
  cluster_name    = var.cluster_name
  cluster_version = "1.18"

  #  This should be subnet_ids
  subnets = var.private_eks_subnet_ids

  vpc_id = var.eks_vpc_id

  #  do not apply aws-auth configmap file, default true
  #  manage_aws_auth = false

  #  Let me manage IAM role for cluster
  manage_cluster_iam_resources = false
  cluster_iam_role_name        = var.cluster_iam_role_name

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = false

  #  let me manage IAM resources for workers
  manage_worker_iam_resources = false

  write_kubeconfig = false

  worker_groups = [
    {
      name                      = var.node_group_name
      instance_type             = var.node_instance_type
      iam_instance_profile_name = var.nodegroup_role_name
      asg_desired_capacity      = 1
      asg_min_size              = 1
      asg_max_size              = 5
    }
  ]

  # node_groups = {
  #   ng1 = {
  #     desired_capacity = 1
  #    max_capacity     = 10
  #    min_capacity     = 1
  #
  #    instance_type = var.node_instance_type
  #    iam_role_arn  = var.nodegroup_arn
  #  }
  #}
}

resource "aws_security_group_rule" "allow_https" {
  description = "All bastion host in public subnet to access EKS API"
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = var.vpc_cidr

  security_group_id = module.private_eks.cluster_security_group_id
}
