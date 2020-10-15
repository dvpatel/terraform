resource "aws_instance" "mybastion" {
  ami                  = var.bastion_ami_id
  instance_type        = var.bastion_instance_type
  key_name             = var.bastion_ssh_key
  subnet_id            = var.bastion_subnet
  iam_instance_profile = var.bastion_instance_profile
  user_data            = file(var.bastion_user_data)
  security_groups      = [aws_security_group.bastion_ssh_sg.id]

  tags = {
    Name = "bastion-host"
  }

  depends_on = [aws_eks_cluster.dev_eks, aws_eks_node_group.dev_mng]
}


resource "aws_security_group" "bastion_ssh_sg" {
  name = "bastion-ssh-sg"
  vpc_id = var.public_vpc
  ingress {
    cidr_blocks = [ "24.218.157.167/32" ]
    from_port = 22
    to_port = 22
    protocol = "tcp"
  }

  // Terraform removes the default rule
  egress {
    from_port = 0
     to_port = 0
     protocol = "-1"
     cidr_blocks = ["0.0.0.0/0"]
  }
}
