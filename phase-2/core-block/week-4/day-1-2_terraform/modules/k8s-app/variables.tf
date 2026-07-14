variable "app_name" {
  type        = string
  description = "Name of the app being deployed"
}

variable "image" {
  type        = string
  description = "Container image and tag used for Deployment"
}

variable "replicas" {
  type        = number
  description = "Number of Pods desired in Deployment"
  default     = 1
}

variable "env" {
  type        = string
  description = "Environment name such as dev, stg"
}

variable "ingress_host" {
  type        = string
  description = "Domain name used to configure routing for Ingress"
}