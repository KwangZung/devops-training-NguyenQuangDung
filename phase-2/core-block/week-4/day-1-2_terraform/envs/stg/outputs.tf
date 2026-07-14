output "stg_service_name" {
  value       = module.stg_app.service_name
  description = "Name of the Kubernetes Service created for Staging environment"
}

output "stg_service_endpoint" {
  value       = module.stg_app.service_endpoint
  description = "Internal Cluster DNS path of the Service in Staging environment"
}

output "stg_ingress_hostname" {
  value       = module.stg_app.ingress_hostname
  description = "Domain name configured for Ingress in Staging environment"
}
