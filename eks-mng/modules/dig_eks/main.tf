data "aws_availability_zones" "available" {
}

data "aws_vpcs" "eks" {
  tags = {
    Name = var.vpc_name
  }
}

data "aws_vpc" "eks" {
  count = length(data.aws_vpcs.eks.ids)
  id    = tolist(data.aws_vpcs.eks.ids)[count.index]
}

data "aws_vpc" "selected" {
  count = length(data.aws_vpcs.eks.ids)
  id    = data.aws_vpc.eks[count.index].id
}

data "aws_subnet_ids" "private" {
  vpc_id = data.aws_vpc.selected[0].id

  tags = {
    tier = "private"
  }
}

module "private_eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = var.cluster_name
  cluster_version = "1.18"

  #  This should be subnet_ids
  subnets = data.aws_subnet_ids.private.ids

  #  Derive vpc_id based on name
  vpc_id = data.aws_vpc.selected[0].id

  #  do not apply aws-auth configmap file, default true
  #  manage_aws_auth = false

  #  Let me manage IAM role for cluster
  manage_cluster_iam_resources    = false
  cluster_iam_role_name           = var.cluster_iam_role_name
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = false

  #  let me manage IAM resources for workers
  manage_worker_iam_resources = false

  worker_groups = [
    {
      name                      = var.mng_node_group_name
      instance_type             = var.mng_node_instance_types
      iam_instance_profile_name = var.nodegroup_role_name
      kubelet_extra_args        = "--node-labels=lifecycle=OnDemand,aws.amazon.com/spot=false"
    },
    {
      name                                     = var.spot_node_group_name
      override_instance_types                  = var.spot_node_instance_types
      iam_instance_profile_name                = var.nodegroup_role_name
      asg_min_size                             = 2
      asg_max_size                             = 5
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = 0
      spot_allocation_strategy                 = "capacity-optimized"
      spot_max_price                           = 0.017
      kubelet_extra_args                       = "--node-labels=lifecycle=Ec2Spot,intent=apps,aws.amazon.com/spot=true --register-with-taints=spotInstance=true:PreferNoSchedule"
      tags = ["k8s.io/cluster-autoscaler/node-template/label/lifecycle=Ec2Spot", "k8s.io/cluster-autoscaler/node-template/label/intent=apps","k8s.io/cluster-autoscaler/node-template/label/aws.amazon.com/spot=true","k8s.io/cluster-autoscaler/node-template/taint/spotInstance=true:PreferNoSchedule"]
    }
  ]
}

resource "aws_security_group_rule" "allow_https" {
  description       = "Allow bastion host in public subnet to access EKS API"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = data.aws_vpc.selected.*.cidr_block
  security_group_id = module.private_eks.cluster_security_group_id
}
