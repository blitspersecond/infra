resource "aws_ecr_repository" "traefik" {
  name                 = "traefik-mirror"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}
