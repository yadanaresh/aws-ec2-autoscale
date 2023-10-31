output "vpc_id" {
  value = aws_vpc.my_vpc.id
}

output "subnet_id_a" {
  value = aws_subnet.subnet_a.id
}

output "subnet_id_b" {
  value = aws_subnet.subnet_b.id
}

output "load_balancer_dns" {
  value = aws_lb.my_alb.dns_name
}

# Add other outputs for resources you want to retrieve
