terraform {
  required_version = ">= 0.12.6"
}

provider "aws" {
  region  = var.region
  profile = var.profile
}

provider "local" {
}

provider "null" {
}

provider "template" {
}

module "vpc_eks" {
  source       = "./modules/dig_vpc"
  vpc_name     = var.vpc_name
  cluster_name = var.cluster_name
}

module "app_bastion" {
  source = "./modules/dig_bastion"
  vpc_id = module.vpc_eks.vpc_id

  #  count                = length(module.vpc_eks.public_subnet_ids)
  count                = 1
  vpc_public_subnet_id = element(tolist(module.vpc_eks.public_subnet_ids.ids), count.index)

  depends_on = [module.vpc_eks]
}
