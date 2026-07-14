output "stg_vpc_id" {
  value       = module.stg_network.vpc_id
  description = "ID of the VPC created in Staging environment"
}

output "stg_instance_public_ip" {
  value       = module.stg_compute.instance_public_ip
  description = "Public IP of the EC2 instance in Staging environment"
}