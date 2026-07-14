output "service_name" {
  value       = kubernetes_service.app.metadata[0].name
  description = "Name of the Kubernetes Service created"
}

output "service_endpoint" {
  value       = "${kubernetes_service.app.metadata[0].name}.${kubernetes_service.app.metadata[0].namespace != "" ? kubernetes_service.app.metadata[0].namespace : "default"}.svc.cluster.local"
  description = "Internal Cluster DNS path of the Service"
}

output "ingress_hostname" {
  value       = var.ingress_host
  description = "Domain name configured for the Ingress system"
}