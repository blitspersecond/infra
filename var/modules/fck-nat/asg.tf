resource "aws_security_group" "fc_nat_sg" {
  name        = "fc_nat_sg"
  description = "Allow outbound traffic from the NAT Gateway"
  vpc_id      = var.vpc_id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
