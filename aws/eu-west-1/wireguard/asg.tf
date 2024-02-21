locals {
  host-types = [
    "t3.micro", # $0.0104 per hour
    "t2.micro", # $0.0136 per hour
  ]
}

resource "aws_launch_template" "wireguard" {
  name     = "${var.environment}-wireguard-cluster-node"
  image_id = data.aws_ami.al2023.id
  iam_instance_profile {
    name = aws_iam_instance_profile.wireguard_iam_profile.name
  }
  vpc_security_group_ids = [
    aws_security_group.wireguard.id,
  ]
  instance_type = "t2.micro"
  user_data     = base64encode(templatefile("init.sh", { environment = var.environment }))
  monitoring {
    enabled = false
  }
  metadata_options {
    http_tokens = "required"
  }
  lifecycle {
    create_before_destroy = true
  }
  tags = merge(
    local.tags,
    {
      Name = "${var.environment}-wireguard"
      # eipalloc = aws_eip.wireguard.allocation_id
    }
  )

  update_default_version = true
}

resource "aws_autoscaling_group" "wireguard" {
  desired_capacity    = 0
  max_size            = 1
  min_size            = 0
  name                = "${var.environment}-wireguard"
  vpc_zone_identifier = data.aws_subnets.hub.ids
  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = 0
      spot_allocation_strategy                 = "price-capacity-optimized"
    }
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.wireguard.id
        version            = "$Latest"
      }
      override {
        instance_type = local.host-types[0]
      }
      override {
        instance_type = local.host-types[1]
      }
    }
  }
  tag {
    key                 = "Name"
    value               = "${var.environment}-wireguard"
    propagate_at_launch = true
  }
  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }
}
