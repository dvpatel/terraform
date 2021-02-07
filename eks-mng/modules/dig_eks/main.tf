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

  #  Let me manage IAM role for cluster
  manage_cluster_iam_resources    = false
  cluster_iam_role_name           = var.cluster_iam_role_name
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = false

  #  let me manage IAM resources for workers
  manage_worker_iam_resources = false

  #  Added as workaround since default gp3 is not supported
  workers_group_defaults = {
  	root_volume_type = "gp2"
  }

  worker_groups = [
    {
      name                      = var.mng_node_group_name
      instance_type             = var.mng_node_instance_types
      asg_desired_capacity      = 2
      asg_min_size              = 2
      asg_max_size              = 10
      iam_instance_profile_name = var.nodegroup_role_name
      kubelet_extra_args        = "--node-labels=lifecycle=OnDemand"
    },
    {
      name                                     = var.spot_node_group_name_grp1
      override_instance_types                  = var.spot_node_instance_types_grp1
      iam_instance_profile_name                = var.nodegroup_role_name
      asg_desired_capacity                     = 2
      asg_min_size                             = 2
      asg_max_size                             = 10
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = 0
      spot_allocation_strategy                 = "capacity-optimized"
      spot_max_price                           = 0.017
      kubelet_extra_args                       = "--node-labels=lifecycle=Ec2Spot,intent=apps,aws.amazon.com/spot=true"
      tags = [
        {
          key                 = "k8s.io/cluster-autoscaler/node-template/label/lifecycle",
          value               = "Ec2Spot",
          propagate_at_launch = true
        },
        {
          key                 = "k8s.io/cluster-autoscaler/node-template/label/intent",
          value               = "apps",
          propagate_at_launch = true
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/enabled"
          "propagate_at_launch" = "false"
          "value"               = "true"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/${var.cluster_name}"
          "propagate_at_launch" = "false"
          "value"               = "true"
        }
      ]
    },
    {
      name                                     = var.spot_node_group_name_grp2
      override_instance_types                  = var.spot_node_instance_types_grp2
      iam_instance_profile_name                = var.nodegroup_role_name
      asg_desired_capacity                     = 2
      asg_min_size                             = 2
      asg_max_size                             = 10
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = 0
      spot_allocation_strategy                 = "capacity-optimized"
      spot_max_price                           = 0.017
      kubelet_extra_args                       = "--node-labels=lifecycle=Ec2Spot,intent=apps,aws.amazon.com/spot=true"
      tags = [
        {
          key                 = "k8s.io/cluster-autoscaler/node-template/label/lifecycle",
          value               = "Ec2Spot",
          propagate_at_launch = true
        },
        {
          key                 = "k8s.io/cluster-autoscaler/node-template/label/intent",
          value               = "apps",
          propagate_at_launch = true
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/enabled"
          "propagate_at_launch" = "false"
          "value"               = "true"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/${var.cluster_name}"
          "propagate_at_launch" = "false"
          "value"               = "true"
        }
      ]
    }
  ]
}


#  Update kubeconfig; setup certmgr, cluster autoscaler, etc.
resource "null_resource" "eks_post_setup" {
  provisioner "local-exec" {
    command = "$HOME/terraform/eks-mng/post_setup.sh ${var.region} ${var.cluster_name}"
  }
  depends_on = [module.private_eks]
}


# module "alb_ingress_controller" {
#   source  = "iplabs/alb-ingress-controller/kubernetes"
#   aws_alb_ingress_controller_version = "2.0.0"
# 
#   k8s_cluster_type = "eks"
#   k8s_namespace    = "default"
# 
#   aws_region_name  = var.region
#   aws_vpc_id = data.aws_vpc.selected[0].id
#   k8s_cluster_name = var.cluster_name
# 
#   depends_on = [module.private_eks]
# }

resource "aws_security_group_rule" "allow_https" {
  description       = "Allow bastion host in public subnet to access EKS API"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = data.aws_vpc.selected.*.cidr_block
  security_group_id = module.private_eks.cluster_security_group_id
}
