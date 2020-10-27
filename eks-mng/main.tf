terraform {
  required_version = ">= 0.12.6"
}

provider "aws" {
  version = ">= 2.28.1"
  region  = var.region
  profile = var.profile
}

provider "local" {
  version = "~> 1.2"
}

provider "null" {
  version = "~> 2.1"
}

provider "template" {
  version = "~> 2.1"
}

module "app_eks" {
  source       = "./modules/dig_eks"
  vpc_name     = var.vpc_name
  cluster_name = var.cluster_name
}
