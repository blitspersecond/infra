resource "aws_route53_zone" "region" {
  name = "${data.aws_region.current.name}.${var.domain}"
  tags = local.tags
}

resource "aws_route53_record" "region_ns" {
  zone_id = aws_route53_zone.region.zone_id
  name    = "${data.aws_region.current.name}.${var.domain}"
  type    = "NS"
  ttl     = "30"
  records = aws_route53_zone.region.name_servers
}

