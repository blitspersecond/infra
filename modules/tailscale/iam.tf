resource "aws_iam_instance_profile" "tailscale_profile" {
  name = "${var.environment}-${var.region}-tailscale-profile"
  role = aws_iam_role.tailscale_role.name
}

data "aws_iam_policy_document" "tailscale_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "tailscale_role" {
  name               = "${var.environment}-${var.region}-tailscale-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.tailscale_assume_role.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
  inline_policy {
    name   = "tailscale_policy"
    policy = data.aws_iam_policy_document.tailscale_policy.json
  }
}

# trivy:ignore:avd-aws-0057 a condition is used to restrict the actions to a specific resource
data "aws_iam_policy_document" "tailscale_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:ModifyInstanceAttribute",
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "ec2:ResourceTag/Name"
      values   = ["${var.environment}-${var.region}-tailscale"]
    }
  }
  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath",
      "ssm:DescribeParameters",
    ]
    resources = [var.auth_key]
  }
}
