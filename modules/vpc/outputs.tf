output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "default_route_table_id" {
  value = aws_vpc.vpc.default_route_table_id
}

output "cidr_block" {
  value = aws_vpc.vpc.cidr_block
}

output "public_subnets" {
  value = values(aws_subnet.public_subnet)[*].id
}
