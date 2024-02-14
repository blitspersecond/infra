resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

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
  # instance_type               = "${local.host-types[0]}"
  user_data = filebase64("init.sh")
  monitoring {
    enabled = false
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
  desired_capacity    = 0
  max_size            = 1
  min_size            = 0
  name                = "${var.environment}-ecs-cluster-node"
  vpc_zone_identifier = data.aws_subnets.spoke.ids
  launch_template {
    id      = aws_launch_template.ecs_cluster_nodes.id
    version = "$Latest"
  }
  tag {
    key                 = "Name"
    value               = "${var.environment}-ecs-cluster-node"
    propagate_at_launch = true
  }
  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }
}

# resource "aws_autoscaling_group" "eks-cluster-worker-nodes-spot" {
#   count                = "${var.enable-spot == "true" ? 1 : 0}"
#   max_size             = "${var.max-host-count}"
#   min_size             = "${var.min-host-count}"
#   name                 = "${var.cluster-name}"
#   vpc_zone_identifier  = "${local.subnet-ids}"

#   mixed_instances_policy {
#     instances_distribution {
#       on_demand_percentage_above_base_capacity = 0
#       spot_instance_pools = 2
#     }
#     launch_template {
#       launch_template_specification {
#         launch_template_id = "${aws_launch_template.eks-cluster-worker-nodes.id}"
#         version = "$$Latest"
#       }

#       override {
#         instance_type = "${local.host-types[0]}"
#       }

#       override {
#         instance_type = "${local.host-types[1]}"
#       }
#     }
#   }

#   tag {
#     key                 = "Name"
#     value               = "${var.cluster-name}"
#     propagate_at_launch = true
#   }

#   tag {
#     key                 = "Environment"
#     value               = "${var.cluster-name}"
#     propagate_at_launch = true
#   }

#   tag {
#     key                 = "kubernetes.io/cluster/${var.cluster-name}"
#     value               = "owned"
#     propagate_at_launch = true
#   }

#   tag {
#     key                 = "k8s.io/cluster-autoscaler/enabled"
#     value               = "true"
#     propagate_at_launch = true
#   }

# }
