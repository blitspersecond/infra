resource "aws_ecr_repository" "hello" {
  name = "hello"
  encryption_configuration {
    encryption_type = "AES256"
  }
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = merge(
    local.tags,
    {
      Name = "${var.environment}-ecs-cluster-node"
    }
  )
}
