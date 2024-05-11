
resource "aws_route53_zone" "zone" {
  name = "${var.region}.${var.environment}.${var.domain}"
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-zone"
    }
  )
}

resource "cloudflare_record" "zone_binding" {
  for_each   = var.cloudflare_root ? toset(aws_route53_zone.zone.name_servers) : toset({})
  zone_id    = data.cloudflare_zone.zone[0].id
  name       = "${var.region}.${var.environment}.${var.domain}"
  type       = "NS"
  value      = each.value
  ttl        = 1
  depends_on = [aws_route53_zone.zone]
}
