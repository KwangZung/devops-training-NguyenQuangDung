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

# Sử dụng biến terraform.workspace để cấu hình động theo từng môi trường
locals {
  env = terraform.workspace

  # Khai báo thông số cấu hình khác biệt của từng môi trường
  env_config = {
    default = {
      replicas     = 1
      ingress_host = "default.demo.local"
    }
    dev = {
      replicas     = 1
      ingress_host = "dev.demo.local"
    }
    stg = {
      replicas     = 3
      ingress_host = "stg.demo.local"
    }
  }

  # Tự động chọn cấu hình tương ứng với workspace hiện tại
  current_config = lookup(local.env_config, local.env, local.env_config["default"])
}

module "app" {
  source = "../modules/k8s-app"

  app_name     = "workspace-app-${local.env}"
  image        = "nginx:alpine"
  replicas     = local.current_config.replicas
  env          = local.env
  ingress_host = local.current_config.ingress_host
}