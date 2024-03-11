data "cloudflare_zone" "blitspersecond_com" {
  name = "blitspersecond.com"
}

output "name" {
  value = data.cloudflare_zone.blitspersecond_com.id
}
