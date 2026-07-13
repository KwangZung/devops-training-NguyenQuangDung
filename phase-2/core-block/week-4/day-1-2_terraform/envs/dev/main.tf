terraform {
  required_version = ">= 1.0.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

module "dev_app" {
  source = "../../modules/k8s-app"

  app_name     = "demo-app-dev"
  image        = "nginx:alpine"
  replicas     = 1
  env          = "dev"
  ingress_host = "dev.demo.local"
}