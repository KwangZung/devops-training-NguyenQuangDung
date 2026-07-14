output "dev_vpc_id" {
  value       = module.dev_network.vpc_id
  description = "ID of the VPC created in Dev environment"
}

output "dev_instance_public_ip" {
  value       = module.dev_compute.instance_public_ip
  description = "Public IP of the EC2 instance in Dev environment"
}