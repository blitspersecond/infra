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
}



# resource "aws_iam_policy" "policy" {
#   name        = "test-policy"
#   description = "A test policy"
#   policy      = data.aws_iam_policy_document.policy.json
# }

# resource "aws_iam_role_policy_attachment" "test-attach" {
#   role       = aws_iam_role.role.name
#   policy_arn = aws_iam_policy.policy.arn
# }

data "aws_iam_policy_document" "ecs_policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "ecs:CreateCluster",
      "ecs:DeregisterContainerInstance",
      "ecs:DiscoverPollEndpoint",
      "ecs:Poll",
      "ecs:RegisterContainerInstance",
      "ecs:StartTelemetrySession",
      "ecs:Submit*",
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "ssm_policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "ssm:DescribeAssociation",
      "ssm:GetDeployablePatchSnapshotForInstance",
      "ssm:GetDocument",
      "ssm:DescribeDocument",
      "ssm:GetManifest",
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:ListAssociations",
      "ssm:ListInstanceAssociations",
      "ssm:PutInventory",
      "ssm:PutComplianceItems",
      "ssm:PutConfigurePackageResult",
      "ssm:UpdateAssociationStatus",
      "ssm:UpdateInstanceAssociationStatus",
      "ssm:UpdateInstanceInformation"
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "ec2messages:AcknowledgeMessage",
      "ec2messages:DeleteMessage",
      "ec2messages:FailMessage",
      "ec2messages:GetEndpoint",
      "ec2messages:GetMessages",
      "ec2messages:SendReply"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ecs_policy" {
  name   = "ecs-policy"
  policy = data.aws_iam_policy_document.ecs_policy_document.json
}

resource "aws_iam_policy" "ssm_policy" {
  name   = "ssm-policy"
  policy = data.aws_iam_policy_document.ssm_policy_document.json
}

resource "aws_iam_role_policy_attachment" "ecs_policy_attach" {
  role       = aws_iam_role.ecs_role.name
  policy_arn = aws_iam_policy.ecs_policy.arn
}

resource "aws_iam_role_policy_attachment" "ssm_policy_attach" {
  role       = aws_iam_role.ecs_role.name
  policy_arn = aws_iam_policy.ssm_policy.arn
}
