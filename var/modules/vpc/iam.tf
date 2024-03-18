resource "aws_iam_instance_profile" "fck_nat_profile" {
  name = "${var.environment}-fck_nat_profile"
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
      "ec2:ModifyNetworkInterfaceAttribute",
      "ec2:AssociateAddress",
      "ec2:DisassociateAddress",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "fck_nat_role" {
  name               = "${var.environment}-fck-nat-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.fck_nat_assume_role.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
  inline_policy {
    name   = "fck_nat_network_policy"
    policy = data.aws_iam_policy_document.fck_nat_network_policy.json
  }
}

# resource "aws_iam_instance_profile" "main" {
#   name = var.name
#   role = aws_iam_role.main.name

#   tags = var.tags
# }

# data "aws_iam_policy_document" "main" {
#   statement {
#     sid    = "ManageNetworkInterface"
#     effect = "Allow"
#     actions = [
#       "ec2:AttachNetworkInterface",
#       "ec2:ModifyNetworkInterfaceAttribute",
#     ]
#     resources = [
#       "*",
#     ]
#     condition {
#       test     = "StringEquals"
#       variable = "ec2:ResourceTag/Name"
#       values   = [var.name]
#     }
#   }

#   dynamic "statement" {
#     for_each = length(var.eip_allocation_ids) != 0 ? ["x"] : []

#     content {
#       sid    = "ManageEIPAllocation"
#       effect = "Allow"
#       actions = [
#         "ec2:AssociateAddress",
#         "ec2:DisassociateAddress",
#       ]
#       resources = [
#         "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:elastic-ip/${var.eip_allocation_ids[0]}",
#       ]
#     }
#   }

#   dynamic "statement" {
#     for_each = length(var.eip_allocation_ids) != 0 ? ["x"] : []

#     content {
#       sid    = "ManageEIPNetworkInterface"
#       effect = "Allow"
#       actions = [
#         "ec2:AssociateAddress",
#         "ec2:DisassociateAddress",
#       ]
#       resources = [
#         "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:network-interface/*"
#       ]
#       condition {
#         test     = "StringEquals"
#         variable = "ec2:ResourceTag/Name"
#         values   = [var.name]
#       }
#     }
#   }

#   dynamic "statement" {
#     for_each = var.use_cloudwatch_agent ? ["x"] : []

#     content {
#       sid    = "CWAgentSSMParameter"
#       effect = "Allow"
#       actions = [
#         "ssm:GetParameter"
#       ]
#       resources = [
#         local.cwagent_param_arn
#       ]
#     }
#   }

#   dynamic "statement" {
#     for_each = var.use_cloudwatch_agent ? ["x"] : []

#     content {
#       sid    = "CWAgentMetrics"
#       effect = "Allow"
#       actions = [
#         "cloudwatch:PutMetricData"
#       ]
#       resources = [
#         "*"
#       ]
#       condition {
#         test     = "StringEquals"
#         variable = "cloudwatch:namespace"
#         values   = [var.cloudwatch_agent_configuration.namespace]
#       }
#     }
#   }
# }

# resource "aws_iam_role" "main" {
#   name = var.name

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Sid    = ""
#         Principal = {
#           Service = "ec2.amazonaws.com"
#         }
#       }
#     ]
#   })

#   inline_policy {
#     name   = "Main"
#     policy = data.aws_iam_policy_document.main.json
#   }

#   tags = var.tags
# }
