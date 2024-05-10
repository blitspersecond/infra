resource "aws_iam_instance_profile" "ecs_profile" {
  name = "ecs_profile"
  role = aws_iam_role.ecs_role.name
}

data "aws_iam_policy_document" "ecs_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ecs_role" {
  name               = "ecs_role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
}
