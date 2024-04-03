resource "aws_eip" "fck_nat_eip" {
  #for_each = flatten(local.vpc_public_ids)
  for_each = local.public_subnets
  domain   = "vpc"
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${each.value}-fck-nat-eip"
    }
  )
}

resource "aws_network_interface" "fck_nat" {
  for_each          = local.public_subnets
  description       = "fck-nat-lt-${each.key} static ENI"
  subnet_id         = each.value
  security_groups   = [aws_security_group.fck_nat_sg.id]
  source_dest_check = false
  tags = merge(var.tags, {
    Name = "${var.environment}-fck-nat-eni"
  })
}

output "az" {
  value = local.public_subnets
}

resource "aws_launch_template" "fck_nat_lt" {
  for_each      = local.public_subnets
  name          = "fck-nat-lt-${each.key}"
  image_id      = data.aws_ami.fck_nat.id
  instance_type = local.host-types[0]
  iam_instance_profile {
    name = aws_iam_instance_profile.fck_nat_profile.name
  }
  network_interfaces {
    description                 = "fck-nat-lt-${each.key} ephemeral public ENI"
    subnet_id                   = each.value
    associate_public_ip_address = true
    security_groups             = [aws_security_group.fck_nat_sg.id]
  }
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${each.key}-fck-nat"
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
  for_each            = local.public_subnets
  name                = "fck-nat-asg-${each.key}"
  max_size            = 1
  min_size            = 1
  desired_capacity    = 1
  health_check_type   = "EC2"
  vpc_zone_identifier = [each.value]

  launch_template {
    id      = aws_launch_template.fck_nat_lt[each.key].id
    version = "$Latest"
  }

  dynamic "tag" {
    for_each = merge(
      var.tags,
      {
        Name = "${var.environment}-${each.key}-fck-nat"
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
