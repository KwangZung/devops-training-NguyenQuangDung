output "public_ip" {
  description = "IP Public của máy chủ Nginx"
  value       = aws_eip.web_eip.public_ip
}

output "instance_id" {
  description = "ID của máy chủ EC2"
  value       = aws_instance.web.id
}