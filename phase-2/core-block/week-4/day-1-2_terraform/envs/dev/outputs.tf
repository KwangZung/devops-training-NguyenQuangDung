output "dev_service_name" {
  value       = module.dev_app.service_name
  description = "Name of the Kubernetes Service created for Dev environment"
}

output "dev_service_endpoint" {
  value       = module.dev_app.service_endpoint
  description = "Internal Cluster DNS path of the Service in Dev environment"
}

output "dev_ingress_hostname" {
  value       = module.dev_app.ingress_hostname
  description = "Domain name configured for Ingress in Dev environment"
}