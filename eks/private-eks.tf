data "aws_subnet_ids" "private_eks_subnet_ids" {
  vpc_id = aws_vpc.private_eks_vpc.id
  depends_on = [aws_subnet.subnet1, aws_subnet.subnet2, aws_subnet.subnet3]
}

resource "aws_eks_cluster" "dev_eks" {
  enabled_cluster_log_types = []
  name                      = var.cluster_name
  role_arn                  = var.cluster_arn

  vpc_config {
    subnet_ids              = data.aws_subnet_ids.private_eks_subnet_ids.ids
    security_group_ids      = [aws_security_group.private_eks_sg.id]
    endpoint_private_access = "true"
    endpoint_public_access  = "true"
  }

  tags = {
    Name = var.cluster_name
  }

  depends_on = [data.aws_subnet_ids.private_eks_subnet_ids]
}

resource "aws_eks_node_group" "dev_mng" {
  cluster_name    = aws_eks_cluster.dev_eks.name
  node_group_name = var.nodegroup_name
  node_role_arn   = var.nodegroup_arn
  subnet_ids      = data.aws_subnet_ids.private_eks_subnet_ids.ids

  ami_type        = "AL2_x86_64"
  instance_types  = ["t3.small"]

  scaling_config {
    desired_size = 1
    min_size     = 1
    max_size     = 3
  }

  tags = {
    Name = var.nodegroup_name
  }

  depends_on = [aws_eks_cluster.dev_eks]
}

data "aws_eks_cluster" "dev_eks" {
  name = aws_eks_cluster.dev_eks.id
}

data "aws_eks_cluster_auth" "dev_eks" {
  name = aws_eks_cluster.dev_eks.id
}

output "endpoint" {
  value = aws_eks_cluster.dev_eks.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.dev_eks.certificate_authority[0].data
}
