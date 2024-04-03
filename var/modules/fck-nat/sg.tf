#tfsec:ignore:aws-ec2-no-public-egress-sgr NAT Gateways require public egress
resource "aws_security_group" "fck_nat_sg" {
  name        = "fck_nat_sg"
  description = "Allow outbound traffic from the NAT Gateway"
  vpc_id      = var.vpc_id
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}