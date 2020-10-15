/**
 * VPC.
 *
 * Virtual network which will be referred to as "secondary" in this example.
 */
resource "aws_vpc" "private_eks_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "private-eks-vpc"
  }
}

/**
 * Subnet.
 *
 * /24 subnet for availability zone "a".
 */
resource "aws_subnet" "subnet1" {
  vpc_id                  = aws_vpc.private_eks_vpc.id
  cidr_block              = "10.0.0.0/18"
  map_public_ip_on_launch = false
  availability_zone       = "${var.region}a"

  tags = {
    Name = "private-eks-vpc-subnet1"
    "kubernetes.io/role/internal-elb" = 1
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    NodegroupName = var.nodegroup_name
  }

}

/**
 * Subnet.
 *
 * /24 subnet for availability zone "b".
 */
resource "aws_subnet" "subnet2" {
  vpc_id                  = aws_vpc.private_eks_vpc.id
  cidr_block              = "10.0.64.0/18"
  map_public_ip_on_launch = false
  availability_zone       = "${var.region}b"

  tags = {
    Name = "private-eks-vpc-subnet2"
    "kubernetes.io/role/internal-elb" = 1
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    NodegroupName = var.nodegroup_name
  }

}

/**
 * Subnet.
 *
 * /24 subnet for availability zone "b".
 */
resource "aws_subnet" "subnet3" {
  vpc_id                  = aws_vpc.private_eks_vpc.id
  cidr_block              = "10.0.128.0/18"
  map_public_ip_on_launch = false
  availability_zone       = "${var.region}c"

  tags = {
    Name = "private-eks-vpc-subnet3"
    "kubernetes.io/role/internal-elb" = 1
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    NodegroupName = var.nodegroup_name
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.private_eks_vpc.id

  tags = {
    Name = "private_route_table"
  }
}

resource "aws_route_table_association" "subnet1_rt" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "subnet2_rt" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "subnet3_rt" {
  subnet_id      = aws_subnet.subnet3.id
  route_table_id = aws_route_table.private_route_table.id
}

/**
 * Security group.
 *  - Outbound traffic unrestricted.
 */
resource "aws_security_group" "private_eks_sg" {
  name_prefix = "private-eks-"
  description = "Security group to govern who can access the endpoints in VPC ${aws_vpc.private_eks_vpc.id}"
  vpc_id      = aws_vpc.private_eks_vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "control_plane_sg" {
  name_prefix = "control-plane-sg-"
  description = "Cluster communication with worker nodes in VPC ${aws_vpc.private_eks_vpc.id}"
  vpc_id      = aws_vpc.private_eks_vpc.id
}

resource "aws_vpc_endpoint" "s3" {
  vpc_endpoint_type = "Gateway"
  vpc_id              = aws_vpc.private_eks_vpc.id
  service_name        = "com.amazonaws.${var.region}.s3"
  route_table_ids     = [ aws_route_table.private_route_table.id ]
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_endpoint_type = "Interface"
  vpc_id       = aws_vpc.private_eks_vpc.id
  service_name = "com.amazonaws.${var.region}.ecr.api"
  private_dns_enabled = true
  security_group_ids = [ aws_security_group.private_eks_sg.id]
  subnet_ids = [aws_subnet.subnet1.id, aws_subnet.subnet2.id, aws_subnet.subnet3.id ]
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_endpoint_type = "Interface"
  vpc_id       = aws_vpc.private_eks_vpc.id
  service_name = "com.amazonaws.${var.region}.ecr.dkr"
  private_dns_enabled = true
  security_group_ids = [ aws_security_group.private_eks_sg.id]
  subnet_ids = [aws_subnet.subnet1.id, aws_subnet.subnet2.id, aws_subnet.subnet3.id ]
}

resource "aws_vpc_endpoint" "ec2" {
  vpc_endpoint_type = "Interface"
  vpc_id       = aws_vpc.private_eks_vpc.id
  service_name = "com.amazonaws.${var.region}.ec2"
  private_dns_enabled = true
  security_group_ids = [ aws_security_group.private_eks_sg.id]
  subnet_ids = [aws_subnet.subnet1.id, aws_subnet.subnet2.id, aws_subnet.subnet3.id ]
}

resource "aws_vpc_endpoint" "logs" {
  vpc_endpoint_type = "Interface"
  vpc_id       = aws_vpc.private_eks_vpc.id
  service_name = "com.amazonaws.${var.region}.logs"
  private_dns_enabled = true
  security_group_ids = [ aws_security_group.private_eks_sg.id]
  subnet_ids = [aws_subnet.subnet1.id, aws_subnet.subnet2.id, aws_subnet.subnet3.id ]
}

resource "aws_vpc_endpoint" "sts" {
  vpc_endpoint_type = "Interface"
  vpc_id       = aws_vpc.private_eks_vpc.id
  service_name = "com.amazonaws.${var.region}.sts"
  private_dns_enabled = true
  security_group_ids = [ aws_security_group.private_eks_sg.id]
  subnet_ids = [aws_subnet.subnet1.id, aws_subnet.subnet2.id, aws_subnet.subnet3.id ]
}
