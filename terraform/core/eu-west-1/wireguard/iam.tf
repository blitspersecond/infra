resource "aws_iam_instance_profile" "wireguard_iam_profile" {
  name = "wireguard-instance-profile"
  role = aws_iam_role.wireguard_iam_role.name
}

data "aws_iam_policy_document" "wireguard_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "wireguard_iam_role" {
  name        = "wireguard-iam-role"
  description = "Wireguard role to allow EC2 operations"
  tags = merge(local.tags, {
    Name = "wireguard-iam-role"
  })
  assume_role_policy = data.aws_iam_policy_document.wireguard_assume_role.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
}

# resource "aws_iam_policy" "wireguard_iam_policy" {
#   name   = "wireguard-policy"
#   policy = <<EOF
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Effect": "Allow",
#             "Action": [
#               "ec2:AssociateAddress",
#               "ec2:AttachNetworkInterface"
#             ],
#             "Resource": [
#               "arn:aws:ec2:*:${data.aws_caller_identity.current.account_id}:elastic-ip/${aws_eip.wireguard.allocation_id}",
#               "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:network-interface/${aws_eip.wireguard.id}"
#             ]
#         },
#         {
#             "Effect": "Allow",
#             "Action": [
#               "ec2:AssociateAddress",
#               "ec2:AttachNetworkInterface"
#             ],
#             "Resource": [
#                 "arn:aws:ec2:*:${data.aws_caller_identity.current.account_id}:instance/*",
#                 "arn:aws:ec2:*:${data.aws_caller_identity.current.account_id}:network-interface/*"
#             ]
#         },
#     ]
# }
# EOF
# }

# resource "aws_iam_role_policy_attachment" "wireguard_iam_ssm_policy" {
#   role       = aws_iam_role.wireguard_iam_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
# }

# resource "aws_iam_role_policy_attachment" "wireguard_iam_policy" {
#   role       = aws_iam_role.wireguard_iam_role.name
#   policy_arn = aws_iam_policy.wireguard_iam_policy.arn
# }
