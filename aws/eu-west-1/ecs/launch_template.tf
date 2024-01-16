# resource "aws_launch_template" "ecs_spot" {
#   name = "ecs-spot"

# }

output "ecs-ami-id" {
  value = data.aws_ami.ecs.id
}
