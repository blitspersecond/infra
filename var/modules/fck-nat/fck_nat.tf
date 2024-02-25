resource "aws_launch_template" "fc_nat_lt" {
  name_prefix   = "fc_nat_lt"
  image_id      = data.aws_ami.fck_nat.id
  instance_type = local.host-types[0]
  user_data     = filebase64("${path.module}/scripts/userdata.sh")
  iam_instance_profile {
    name = aws_iam_instance_profile.fck_nat_profile.name
  }
  vpc_security_group_ids = [aws_security_group.fc_nat_sg.id]
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-ecs-cluster-node"
    }
  )
}

resource "aws_network_interface" "fc_nat_eni" {
  for_each  = toset(data.aws_subnets.vpc_public.ids)
  subnet_id = each.value
}

resource "aws_eip" "fc_nat_eip" {
  for_each = aws_network_interface.fc_nat_eni
  domain   = "vpc"
}

resource "aws_eip_association" "fc_nat_eip_association" {
  for_each             = aws_network_interface.fc_nat_eni
  network_interface_id = each.value.id
  allocation_id        = aws_eip.fc_nat_eip[each.key].id
}

resource "aws_autoscaling_group" "fc_nat_asg" {
  for_each         = toset(data.aws_subnets.vpc_public.ids)
  name             = "fc_nat_asg-${each.key}"
  max_size         = 1
  min_size         = 1
  desired_capacity = 1
  launch_template {
    id      = aws_launch_template.fc_nat_lt.id
    version = "$Latest"
  }
  vpc_zone_identifier = [each.value]
}
