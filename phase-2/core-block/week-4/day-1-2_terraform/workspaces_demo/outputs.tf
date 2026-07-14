output "current_workspace" {
  value       = terraform.workspace
}

output "service_name" {
  value       = module.app.service_name
}

output "ingress_hostname" {
  value       = module.app.ingress_hostname
}