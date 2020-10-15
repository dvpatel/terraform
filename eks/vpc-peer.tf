resource "aws_vpc_peering_connection" "primary2secondary" {
  vpc_id        = var.public_vpc
  peer_vpc_id   = aws_vpc.private_eks_vpc.id
  auto_accept   = true
}

resource "aws_route" "primary2secondary" {
  route_table_id            = "rtb-e784c280"
  destination_cidr_block    = aws_vpc.private_eks_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.primary2secondary.id
}

resource "aws_route" "secondary2primary" {
  route_table_id            = aws_route_table.private_route_table.id 
  destination_cidr_block    = "192.168.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.primary2secondary.id
}
