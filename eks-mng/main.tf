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

module "app_eks" {
  source       = "./modules/dig_eks"
  vpc_name     = var.vpc_name
  cluster_name = var.cluster_name
}
