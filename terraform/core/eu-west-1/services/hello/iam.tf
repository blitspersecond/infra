data "aws_iam_policy_document" "ecs_service_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ecs_service_role" {
  name               = "hello-ecs-service-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_service_assume_role.json
  tags = merge(
    local.tags,
    {
      Name = "hello-ecs-service-role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "ecs_service_role_policy_attachment" {
  role       = aws_iam_role.ecs_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}
