resource "aws_iam_instance_profile" "fck_nat_profile" {
  name = "fck_nat_profile"
  role = aws_iam_role.fck_nat_role.name
}

data "aws_iam_policy_document" "fck_nat_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "fck_nat_network_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:AttachNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:ModifyNetworkInterfaceAttribute"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "fck_nat_role" {
  name               = "nat_role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.fck_nat_assume_role.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
}
