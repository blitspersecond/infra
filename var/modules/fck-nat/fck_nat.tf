# resource "aws_launch_template" "fck_nat_lt" {
#   name_prefix   = "fck_nat_lt"
#   image_id      = data.aws_ami.fck_nat.id
#   instance_type = local.host-types[0]
#   user_data     = filebase64("${path.module}/scripts/userdata.sh")
#   iam_instance_profile {
#     name = aws_iam_instance_profile.fck_nat_profile.name
#   }
#   vpc_security_group_ids = [aws_security_group.fck_nat_sg.id]
#   tags = merge(
#     var.tags,
#     {
#       Name = "${var.environment}-ecs-cluster-node"
#     }
#   )
# }

# resource "aws_network_interface" "fck_nat_eni" {
#   for_each  = toset(data.aws_subnets.vpc_public.ids)
#   subnet_id = each.value
#   tags = merge(
#     var.tags,
#     {
#       Name = "${var.environment}-fck-nat"
#     }
#   )
# }

# resource "aws_eip" "fck_nat_eip" {
#   for_each = aws_network_interface.fck_nat_eni
#   domain   = "vpc"
#   tags = merge(
#     var.tags,
#     {
#       Name = "${var.environment}-fck-nat"
#     }
#   )
# }

# resource "aws_eip_association" "fck_nat_eip_association" {
#   for_each             = aws_network_interface.fck_nat_eni
#   network_interface_id = each.value.id
#   allocation_id        = aws_eip.fck_nat_eip[each.key].id
# }

# resource "aws_autoscaling_group" "fck_nat_asg" {
#   for_each         = toset(data.aws_subnets.vpc_public.ids)
#   name             = "fck_nat_asg-${each.key}"
#   max_size         = 1
#   min_size         = 1
#   desired_capacity = 1
#   launch_template {
#     id      = aws_launch_template.fck_nat_lt.id
#     version = "$Latest"
#   }
#   vpc_zone_identifier = [each.value]
#   tag {
#     key                 = "Name"
#     value               = "${var.environment}-fck-nat"
#     propagate_at_launch = true
#   }
#   tag {
#     key                 = "Environment"
#     value               = var.environment
#     propagate_at_launch = true
#   }
# }
