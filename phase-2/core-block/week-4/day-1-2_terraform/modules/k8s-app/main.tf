resource "kubernetes_deployment" "app" {
  metadata {
    name = "${var.app_name}-deployment"
    labels = {
      app = var.app_name
      env = var.env
    }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = var.app_name
        env = var.env
      }
    }

    template {
      metadata {
        labels = {
          app = var.app_name
          env = var.env
        }
      }

      spec {
        container {
          image = var.image
          name  = var.app_name

          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "app" {
  metadata {
    name = "${var.app_name}-service"
    labels = {
      app = var.app_name
      env = var.env
    }
  }

  spec {
    selector = {
      app = var.app_name
      env = var.env
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_ingress_v1" "app" {
  metadata {
    name = "${var.app_name}-ingress"
    labels = {
      app = var.app_name
      env = var.env
    }
  }

  spec {
    rule {
      host = var.ingress_host
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.app.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}