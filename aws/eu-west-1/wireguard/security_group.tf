resource "aws_security_group" "wireguard" {
  name        = "${var.environment}-wireguard"
  description = "Wireguard security group"
  vpc_id      = data.aws_vpc.spoke.id

  ingress {
    description = "SSH access from home"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Wireguard"
    from_port   = 51820
    to_port     = 51820
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
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
      Name = "${data.aws_region.current.id}-wireguard-${var.environment}"
    }
  )

}

