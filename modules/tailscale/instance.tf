resource "aws_launch_template" "tailscale_lt" {
  name          = "${var.environment}-tailscale-launch-template"
  image_id      = data.aws_ami.al2023.id
  instance_type = "t4g.nano"
  iam_instance_profile {
    name = aws_iam_instance_profile.tailscale_profile.name
  }
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.region}-tailscale"
    }
  )
  user_data = base64encode(templatefile("${path.module}/templates/user_data.sh", {
    TF_AWS_REGION        = var.region,
    TF_TAILSCALE_AUTHKEY = var.auth_key,
    TF_CIDR_BLOCKS       = var.cidr_blocks,
  }))

  network_interfaces {
    description                 = "${var.environment}-tailscale-nic"
    associate_public_ip_address = true
  }

  # Enforce IMDSv2
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
  update_default_version = true
}

resource "aws_autoscaling_group" "tailscale_asg" {
  name                = "${var.environment}-${var.region}-tailscale-asg"
  max_size            = 1
  min_size            = 1
  desired_capacity    = 1
  health_check_type   = "EC2"
  vpc_zone_identifier = var.subnet_ids

  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = 0
      spot_allocation_strategy                 = "lowest-price"
    }
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.tailscale_lt.id
        version            = "$Latest"
      }
      override {
        instance_type = "t4g.nano"
      }
    }
  }

  dynamic "tag" {
    for_each = merge(
      var.tags,
      {
        Name = "${var.environment}-${var.region}-tailscale"
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

