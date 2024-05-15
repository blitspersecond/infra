module "tailscale" {
  source      = "../../../../modules/tailscale"
  auth_key    = data.aws_ssm_parameter.auth_key.arn
  environment = var.environment
  region      = var.region
  tags = merge(
    local.tags,
    {
      Name = "${var.environment}-${var.region}-tailscale"
    }
  )
  subnet_ids  = data.aws_subnets.public.ids
  cidr_blocks = join(",", [data.aws_vpc.core.cidr_block, data.aws_vpc.live.cidr_block])
}
