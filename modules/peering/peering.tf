resource "aws_vpc_peering_connection" "vpc-peering" {
  peer_vpc_id = var.vpc_peer_id
  vpc_id      = var.vpc_id
  tags = merge(
    local.tags,
    {
      Name = "${var.environment}-vpc-peering"
    }
  )
}

resource "aws_vpc_peering_connection_accepter" "vpc-peering" {
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc-peering.id
  auto_accept               = true
  tags = merge(
    local.tags,
    {
      Name = "${var.environment}-vpc-peering"
    }
  )
}

resource "aws_route" "self-to-peer" {
  for_each                  = toset(data.aws_route_tables.vpc.ids)
  route_table_id            = each.value
  destination_cidr_block    = data.aws_vpc.peer.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc-peering.id
}

resource "aws_route" "peer-to-self" {
  for_each                  = toset(data.aws_route_tables.peer.ids)
  route_table_id            = each.value
  destination_cidr_block    = data.aws_vpc.vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc-peering.id
}
