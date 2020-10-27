module "bastion_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name           = "theBastion"
  instance_count = 1

  ami           = "ami-0947d2ba12ee1ff75"
  instance_type = "t2.micro"
  key_name      = var.ssh_key_name
  monitoring    = false

  iam_instance_profile   = var.instance_profile
  user_data              = file(var.user_data_file)
  vpc_security_group_ids = [aws_security_group.bastion_ssh_sg.id]

  subnet_id = var.vpc_public_subnet_id

  tags = {
    Name        = "bastion-host"
    Environment = "dev"
  }
}

resource "aws_security_group" "bastion_ssh_sg" {
  name   = "bastion-ssh-sg"
  vpc_id = var.vpc_id
  ingress {
    cidr_blocks = var.ingress_cidr_block
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  // Terraform removes the default rule
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
