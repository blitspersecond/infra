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
  auto_accept               = true #
  tags = merge(
    local.tags,
    {
      Name = "${var.environment}-vpc-peering"
    }
  )
}

resource "aws_route" "to-peer" {
  route_table_id            = data.aws_vpc.vpc.main_route_table_id
  destination_cidr_block    = data.aws_vpc.peer.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc-peering.id

}

resource "aws_route" "from-peer" {
  route_table_id            = data.aws_vpc.peer.main_route_table_id
  destination_cidr_block    = data.aws_vpc.vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc-peering.id
}

# TODO:
# │ data.aws_route_tables.peer.ids is a list of string, known only after apply
# │ 
# │ The "for_each" set includes values derived from resource attributes that cannot be determined until apply, and so Terraform
# │ cannot determine the full set of keys that will identify the instances of this resource.
# │ 
# │ When working with unknown values in for_each, it's better to use a map value where the keys are defined statically in your
# │ configuration and where only the values contain apply-time results.
# │ 
# │ Alternatively, you could use the -target planning option to first apply only the resources that the for_each value depends
# │ on, and then apply a second time to fully converge.

resource "aws_route" "private-to-peer" {
  for_each                  = toset(data.aws_route_tables.vpc.ids)
  route_table_id            = each.value
  destination_cidr_block    = data.aws_vpc.peer.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc-peering.id
}

resource "aws_route" "private-from-peer" {
  for_each                  = toset(data.aws_route_tables.peer.ids)
  route_table_id            = each.value
  destination_cidr_block    = data.aws_vpc.vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc-peering.id
}
