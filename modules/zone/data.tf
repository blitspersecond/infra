data "cloudflare_zone" "zone" {
  count = var.cloudflare_root ? 1 : 0
  name  = var.domain
}
