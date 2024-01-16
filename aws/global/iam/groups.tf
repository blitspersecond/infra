resource "aws_identitystore_group" "users" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.ssoadmin_instances.identity_store_ids)[0]
  display_name      = "Users"
  description       = "Users"
}

resource "aws_ssoadmin_permission_set" "users" {
  instance_arn = tolist(data.aws_ssoadmin_instances.ssoadmin_instances.arns)[0]
  name         = "users"
  description  = "Users Permission Set"
}

resource "aws_ssoadmin_managed_policy_attachment" "users" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.ssoadmin_instances.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.users.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_ssoadmin_account_assignment" "users" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.ssoadmin_instances.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.users.arn

  principal_id   = aws_identitystore_group.users.group_id
  principal_type = "GROUP"

  target_id   = data.aws_caller_identity.current.account_id
  target_type = "AWS_ACCOUNT"
}

resource "aws_identitystore_group" "admins" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.ssoadmin_instances.identity_store_ids)[0]
  display_name      = "Admins"
  description       = "Administrators"
}

resource "aws_ssoadmin_permission_set" "admins" {
  instance_arn = tolist(data.aws_ssoadmin_instances.ssoadmin_instances.arns)[0]
  name         = "admins"
  description  = "Admins Permission Set"
}

resource "aws_ssoadmin_managed_policy_attachment" "admins" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.ssoadmin_instances.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.admins.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_ssoadmin_account_assignment" "admins" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.ssoadmin_instances.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.admins.arn

  principal_id   = aws_identitystore_group.admins.group_id
  principal_type = "GROUP"

  target_id   = data.aws_caller_identity.current.account_id
  target_type = "AWS_ACCOUNT"

}
