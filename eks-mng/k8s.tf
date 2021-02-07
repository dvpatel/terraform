data "aws_eks_cluster" "cluster" {
  name = module.app_eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.app_eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}
