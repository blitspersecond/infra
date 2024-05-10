resource "aws_eip" "fck_nat_eip" {
  domain = "vpc"
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${data.aws_subnet.public.availability_zone}-fck-nat-eip"
    }
  )
}

resource "aws_network_interface" "fck_nat" {
  description       = "${var.environment}-${data.aws_subnet.public.availability_zone}-fck-nat-eni"
  subnet_id         = data.aws_subnet.public.id
  security_groups   = [aws_security_group.fck_nat_sg.id]
  source_dest_check = false
  tags = merge(var.tags, {
    Name = "${var.environment}-${data.aws_subnet.public.availability_zone}-fck-nat-eni"
  })
}

resource "aws_launch_template" "fck_nat_lt" {
  name          = "${var.environment}-${data.aws_subnet.public.availability_zone}-fck-nat-launch-template"
  image_id      = data.aws_ami.fck_nat.id
  instance_type = local.host-types[0]
  iam_instance_profile {
    name = aws_iam_instance_profile.fck_nat_profile.name
  }
  network_interfaces {
    description                 = "${var.environment}-${data.aws_subnet.public.availability_zone}-fck-nat-ephemeral-nic"
    subnet_id                   = data.aws_subnet.public.id
    associate_public_ip_address = true
    security_groups             = [aws_security_group.fck_nat_sg.id]
  }
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${data.aws_subnet.public.availability_zone}-fck-nat"
    }
  )
  user_data = base64encode(templatefile("${path.module}/templates/user_data.sh", {
    TERRAFORM_ENI_ID = aws_network_interface.fck_nat.id
    TERRAFORM_EIP_ID = aws_eip.fck_nat_eip.allocation_id
  }))

  # Enforce IMDSv2
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
  update_default_version = true
}

resource "aws_autoscaling_group" "fck_nat_asg" {
  name                = "${var.environment}-${data.aws_subnet.public.availability_zone}-fck-nat-asg"
  max_size            = 1
  min_size            = 1
  desired_capacity    = 1
  health_check_type   = "EC2"
  vpc_zone_identifier = [data.aws_subnet.public.id]

  launch_template {
    id      = aws_launch_template.fck_nat_lt.id
    version = "$Latest"
  }

  dynamic "tag" {
    for_each = merge(
      var.tags,
      {
        Name = "${var.environment}-${data.aws_subnet.public.availability_zone}-fck-nat"
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

resource "aws_route" "fck_nat_route" {
  route_table_id         = data.aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_network_interface.fck_nat.id
}
