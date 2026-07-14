output "instance_id" {
  value       = aws_instance.app.id
  description = "ID của Instance EC2 vừa tạo"
}

output "instance_public_ip" {
  value       = aws_instance.app.public_ip
  description = "IP công cộng của Instance EC2"
}