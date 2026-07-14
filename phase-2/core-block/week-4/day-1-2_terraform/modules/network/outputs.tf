output "vpc_id" {
  value       = aws_vpc.this.id
  description = "ID của VPC vừa tạo"
}

output "subnet_id" {
  value       = aws_subnet.this.id
  description = "ID của Subnet vừa tạo"
}