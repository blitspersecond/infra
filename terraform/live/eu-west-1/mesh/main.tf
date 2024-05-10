module "peering" {
  source      = "../../../../modules/peering"
  vpc_id      = data.aws_vpc.local.id
  vpc_peer_id = data.aws_vpc.core.id
  environment = var.environment
  tags = merge(
    local.tags,
    {
      Name = "${var.environment}-vpc-peering"
    }
  )
}
