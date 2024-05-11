resource "aws_launch_template" "ecs_cluster_nodes" {
  name     = "${var.environment}-ecs-cluster-node"
  image_id = data.aws_ami.ecs.id
  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_profile.name
  }
  vpc_security_group_ids = [
    aws_security_group.ecs.id
  ]
  instance_type = "t2.micro"
  user_data     = base64encode(templatefile("templates/init.sh", { environment = var.environment }))
  monitoring {
    enabled = false
  }
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  lifecycle {
    create_before_destroy = true
  }
  tags = merge(
    local.tags,
    {
      Name = "${var.environment}-ecs-cluster-node"
    }
  )
  update_default_version = true
}

resource "aws_autoscaling_group" "ecs_cluster_nodes" {
  desired_capacity    = 2
  max_size            = 3
  min_size            = 0
  name                = "${var.environment}-ecs-cluster-node"
  vpc_zone_identifier = data.aws_subnets.private.ids
  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = 0
      spot_allocation_strategy                 = "price-capacity-optimized"
    }
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.ecs_cluster_nodes.id
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
  dynamic "tag" {
    for_each = merge(
      local.tags,
      {
        Name = "${var.environment}-ecs-cluster-node"
      }
    )
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

