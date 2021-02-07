terraform {
  required_version = ">= 0.12.6"
}

terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = ">= 2.0.2"
    }
  }
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
