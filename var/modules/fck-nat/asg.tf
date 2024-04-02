resource "aws_eip" "fck_nat_eip" {
  for_each = var.availability_zones
  domain   = "vpc"
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${each.value}-fck-nat-eip"
    }
  )
}

resource "aws_network_interface" "fck_nat" {
  for_each          = var.availability_zones
  description       = "fck-nat-lt static private ENI"
  subnet_id         = local.vpc_private_ids[each.key]
  security_groups   = [aws_security_group.fck_nat_sg.id]
  source_dest_check = false

  tags = merge(var.tags, {
    Name = "${var.environment}-fck-nat-eni"
  })
}

resource "aws_launch_template" "fck_nat_lt" {
  for_each      = var.availability_zones
  name          = "fck-nat-lt-${each.value}"
  image_id      = data.aws_ami.fck_nat.id
  instance_type = local.host-types[0]
  iam_instance_profile {
    name = aws_iam_instance_profile.fck_nat_profile.name
  }
  network_interfaces {
    description                 = "fck-nat-lt ephemeral public ENI"
    subnet_id                   = local.vpc_public_ids[each.key]
    associate_public_ip_address = true
    security_groups             = [aws_security_group.fck_nat_sg.id]
  }
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-fck-nat"
    }
  )
  user_data = base64encode(templatefile("${path.module}/templates/user_data.sh", {
    TERRAFORM_ENI_ID = aws_network_interface.fck_nat[each.key].id
    TERRAFORM_EIP_ID = aws_eip.fck_nat_eip[each.key].allocation_id
  }))

  # Enforce IMDSv2
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
  update_default_version = true
}

resource "aws_autoscaling_group" "fck_nat_asg" {
  for_each            = var.availability_zones
  name                = "fck-nat-asg-${uuid()}"
  max_size            = 1
  min_size            = 1
  desired_capacity    = 1
  health_check_type   = "EC2"
  vpc_zone_identifier = [data.aws_subnets.vpc_public.ids[each.key]]

  launch_template {
    id      = aws_launch_template.fck_nat_lt[each.key].id
    version = "$Latest"
  }

  dynamic "tag" {
    for_each = merge(
      var.tags,
      {
        Name = "${var.environment}-${each.value}-fck-nat"
      }
    )
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  timeouts {
    delete = "15m"
  }
}
