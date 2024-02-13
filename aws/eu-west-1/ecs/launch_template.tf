output "ecs-ami-id" {
  value = data.aws_ami.ecs.id
}

# https://www.teracloud.io/single-post/optimize-your-costs-with-aws-spot-instances-and-terraform-in-just-a-few-steps

resource "aws_launch_template" "ecs_cluster_nodes" {
  name     = "${var.environment}-ecs-cluster-node"
  image_id = data.aws_ami.ecs.id
  # iam_instance_profile        = { name = "${aws_iam_instance_profile.eks-cluster-worker-nodes.name}" }
  vpc_security_group_ids = [
    aws_security_group.ecs.id
  ]
  # key_name                    = "${var.ssh-key-name}"
  # instance_type               = "${local.host-types[0]}"
  # user_data                   = "${base64encode(element(data.template_file.userdata.*.rendered, count.index))}"
  monitoring {
    enabled = false
  }
  lifecycle {
    create_before_destroy = true
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
