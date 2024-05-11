resource "aws_security_group" "cluster_origin_alb_sg" {
  name        = "${var.environment}-origin-alb-sg"
  description = "Allow HTTP and HTTPS traffic"
  vpc_id      = data.aws_vpc.local.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.tags,
    {
      Name = "${var.environment}-origin-alb-sg"
    }
  )
}

resource "aws_alb" "cluster_origin_alb" {
  name               = "${var.environment}-origin-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.cluster_origin_alb_sg.id]
  subnets            = data.aws_subnets.public.ids
  tags = merge(
    local.tags,
    {
      Name = "${var.environment}-origin-alb"
    }
  )
}

resource "aws_alb_listener" "cluster_origin_alb_http" {
  load_balancer_arn = aws_alb.cluster_origin_alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

variable "domain" {
  type        = string
  default     = ""
  description = "domain name"
}

resource "aws_route53_record" "cluster_origin_alb" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "origin.${var.region}.${var.environment}.${var.domain}"
  type    = "A"
  alias {
    name                   = aws_alb.cluster_origin_alb.dns_name
    zone_id                = aws_alb.cluster_origin_alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_acm_certificate" "cert" {
  domain_name       = "origin.${var.region}.${var.environment}.${var.domain}"
  validation_method = "DNS"
  tags = merge(
    local.tags,
    {
      Name = "${var.environment}-origin-alb-cert"
    }
  )
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [aws_route53_record.cluster_origin_alb]
}

resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.primary.zone_id
}

resource "aws_alb_listener" "cluster_origin_alb_https" {
  load_balancer_arn = aws_alb.cluster_origin_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate_validation.cert_validation.certificate_arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "TLS Fixed response content"
      status_code  = "200"
    }
  }
}
