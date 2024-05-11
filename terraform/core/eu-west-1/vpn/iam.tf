resource "aws_iam_instance_profile" "vpn_profile" {
  name = "vpn_profile"
  role = aws_iam_role.vpn_role.name
}

data "aws_iam_policy_document" "vpn_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "vpn_role" {
  name               = "vpn_role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.vpn_assume_role.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
  inline_policy {
    name   = "fck_nat_network_policy"
    policy = data.aws_iam_policy_document.vpn_network_policy.json
  }
}

# trivy:ignore:avd-aws-0057 a condition is used to restrict the actions to a specific resource
data "aws_iam_policy_document" "vpn_network_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:ModifyInstanceAttribute",
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "ec2:ResourceTag/Name"
      values   = ["${var.environment}-vpn"]
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
    resources = [data.aws_ssm_parameter.tailscale_auth_key.arn]
  }
}
