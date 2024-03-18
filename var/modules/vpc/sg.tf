resource "aws_security_group" "fck_nat_sg" {
  name        = "fck_nat_sg"
  description = "Allow outbound traffic from the NAT Gateway"
  vpc_id      = aws_vpc.vpc.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
