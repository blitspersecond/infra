
resource "aws_route53_zone" "region" {
  name = "${var.region}.${var.environment}.${var.domain}"
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-zone"
    }
  )
}

data "cloudflare_zone" "zone" {
  name = var.domain
}

resource "cloudflare_record" "region_ns" {
  for_each = toset(aws_route53_zone.region.name_servers)
  zone_id  = data.cloudflare_zone.zone.id
  name     = "${var.region}.${var.environment}.${var.domain}"
  type     = "NS"
  value    = each.value
  ttl      = 1
}
