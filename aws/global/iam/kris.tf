resource "aws_identitystore_user" "kris" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.ssoadmin_instances.identity_store_ids)[0]
  user_name         = "kris"
  display_name      = "Kris Holdich"
  name {
    given_name  = "Kris"
    family_name = "Holdich"
  }
  emails {
    value   = "kris@smkd.net"
    primary = true
  }
}

resource "aws_identitystore_group_membership" "kris-admins" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.ssoadmin_instances.identity_store_ids)[0]
  group_id          = aws_identitystore_group.admins.group_id
  member_id         = aws_identitystore_user.kris.user_id
}

resource "aws_identitystore_group_membership" "kris-users" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.ssoadmin_instances.identity_store_ids)[0]
  group_id          = aws_identitystore_group.users.group_id
  member_id         = aws_identitystore_user.kris.user_id
}
