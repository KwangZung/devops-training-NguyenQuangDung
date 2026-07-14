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

module "stg_app" {
  source = "../../modules/k8s-app"

  app_name     = "demo-app-stg"
  image        = "nginx:alpine"
  replicas     = 3
  env          = "stg"
  ingress_host = "stg.demo.local"
}
