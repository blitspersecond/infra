resource "aws_security_group" "ecs" {
  name        = "${var.environment}-ecs"
  description = "ECS security group"
  vpc_id      = data.aws_vpc.spoke.id

  ingress {
    description = "SSH access from hub"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.hub.cidr_block]
  }

  egress {
    description = "All traffic to the internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.tags,
    {
      Name = "${data.aws_region.current.id}-ecs-${var.environment}"
    }
  )

}

