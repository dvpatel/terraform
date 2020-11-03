data "aws_availability_zones" "available" {
}

module "vpc_for_eks" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs = var.vpc_azs

  private_subnets = var.vpc_private_subnets
  public_subnets  = var.vpc_public_subnets

  enable_nat_gateway = var.vpc_enable_nat_gateway
  single_nat_gateway = var.vpc_enable_single_nat_gateway

  enable_dns_support   = true
  enable_dns_hostnames = true

  vpc_tags = {
    Name = var.vpc_name
    Environment = "dev"
  }

  public_subnet_tags = {
    "tier"                                      = "public"
    # "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    # "kubernetes.io/role/elb"                    = "1"
  }

  private_subnet_tags = {
    "tier"                                      = "private"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
}

/**
 * Security group.
 *  - Outbound traffic unrestricted.
 */
resource "aws_security_group" "private_eks_sg" {
  name_prefix = join("-", [var.vpc_name])
  vpc_id      = module.vpc_for_eks.vpc_id
  description = "Security group to govern who can access the endpoints in VPC ${module.vpc_for_eks.vpc_id}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [module.vpc_for_eks.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-cluster-sg"
  }
}

data "aws_subnet_ids" "private" {
  vpc_id = module.vpc_for_eks.vpc_id

  tags = {
    tier = "private"
  }

  depends_on = [module.vpc_for_eks.private_subnets]
}

data "aws_subnet_ids" "public" {
  vpc_id = module.vpc_for_eks.vpc_id

  tags = {
    tier = "public"
  }

  depends_on = [module.vpc_for_eks.public_subnets]
}
