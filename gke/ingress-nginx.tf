# resource "kubernetes_service" "ingress-nginx" {
#   metadata {
#     name        = "ingress-nginx"
#     namespace   = "${var.ingress_nginx_namespace}"
#   }

#   spec {
#     external_traffic_policy = "Local"

#     port {
#       name        = "http"
#       port        = "80"
#       protocol    = "TCP"
#       target_port = "http"
#     }

#     port {
#       name        = "https"
#       port        = "443"
#       protocol    = "TCP"
#       target_port = "https"
#     }

#     selector "app" "kubernetes" {
#       "io/name"    = "ingress-nginx"
#       "io/part-of" = "ingress-nginx"
#     }

#     type             = "LoadBalancer"
#   }
# }
