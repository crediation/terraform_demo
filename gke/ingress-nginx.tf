resource "kubernetes_config_map" "ingress-nginx-config" {
  metadata {
    labels = {
      "app.kubernetes.io/name"    = "ingress-nginx"
      "app.kubernetes.io/part-of" = "ingress-nginx"
    }
    name      = "nginx-configuration"
    namespace = "${kubernetes_namespace.ingress_nginx.metadata.0.name}"
  }
}

resource "kubernetes_config_map" "ingress-nginx-tcp-services" {
  metadata {
    labels = {
      "app.kubernetes.io/name"    = "ingress-nginx"
      "app.kubernetes.io/part-of" = "ingress-nginx"
    }
    name      = "tcp-services"
    namespace = "${kubernetes_namespace.ingress_nginx.metadata.0.name}"
  }
}

resource "kubernetes_config_map" "ingress-nginx-udp-services" {
  metadata {
    labels = {
      "app.kubernetes.io/name"    = "ingress-nginx"
      "app.kubernetes.io/part-of" = "ingress-nginx"
    }
    name      = "udp-services"
    namespace = "${kubernetes_namespace.ingress_nginx.metadata.0.name}"
  }
}

resource "kubernetes_service_account" "nginx-ingress-serviceaccount" {
  metadata {
    labels = {
      "app.kubernetes.io/name"    = "ingress-nginx"
      "app.kubernetes.io/part-of" = "ingress-nginx"
    }
    name      = "nginx-ingress-serviceaccount"
    namespace = "${kubernetes_namespace.ingress_nginx.metadata.0.name}"
  }
}

resource "kubernetes_cluster_role" "ingress-nginx-cluster-role" {
  metadata {
    name = "nginx-ingress-clusterrole"
    labels = {
      "app.kubernetes.io/name"    = "ingress-nginx"
      "app.kubernetes.io/part-of" = "ingress-nginx"
    }
  }
  rule {
    api_groups = [""]
    resources  = ["configmaps", "endpoints", "nodes", "pods", "secrets"]
    verbs      = ["list", "watch"]
  }
  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["get"]
  }
  rule {
    api_groups = [""]
    resources  = ["services"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = [""]
    resources  = ["events"]
    verbs      = ["create", "patch"]
  }
  rule {
    api_groups = ["extensions", "networking.k8s.io"]
    resources  = ["ingresses"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["extensions", "networking.k8s.io"]
    resources  = ["ingresses/status"]
    verbs      = ["update"]
  }
}

resource "kubernetes_role" "nginx-ingress-role" {
  metadata {
    name      = "nginx-ingress-role"
    namespace = "${kubernetes_namespace.ingress_nginx.metadata.0.name}"
    labels = {
      "app.kubernetes.io/name"    = "ingress-nginx"
      "app.kubernetes.io/part-of" = "ingress-nginx"
    }
  }
  rule {
    api_groups = [""]
    resources  = ["configmaps", "pods", "secrets", "namespaces"]
    verbs      = ["get"]
  }
  rule {
    api_groups     = [""]
    resources      = ["configmaps"]
    resource_names = ["ingress-controller-leader-nginx"]
    verbs          = ["get", "update"]
  }
  rule {
    api_groups = [""]
    resources  = ["configmaps"]
    verbs      = ["create"]
  }
  rule {
    api_groups = [""]
    resources  = ["endpoints"]
    verbs      = ["get"]
  }
}

resource "kubernetes_role_binding" "nginx-ingress-role-nisa-binding" {
  metadata {
    name      = "nginx-ingress-role-nisa-binding"
    namespace = "${kubernetes_namespace.ingress_nginx.metadata.0.name}"
    labels = {
      "app.kubernetes.io/name"    = "ingress-nginx"
      "app.kubernetes.io/part-of" = "ingress-nginx"
    }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "nginx-ingress-role"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "nginx-ingress-serviceaccount"
    namespace = "${kubernetes_namespace.ingress_nginx.metadata.0.name}"
  }
}

resource "kubernetes_cluster_role_binding" "nginx-ingress-clusterrole-nisa-binding" {
  metadata {
    name = "nginx-ingress-clusterrole-nisa-binding"
    labels = {
      "app.kubernetes.io/name"    = "ingress-nginx"
      "app.kubernetes.io/part-of" = "ingress-nginx"
    }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "nginx-ingress-clusterrole"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "nginx-ingress-serviceaccount"
    namespace = "${kubernetes_namespace.ingress_nginx.metadata.0.name}"
  }
}

resource "kubernetes_deployment" "nginx-ingress-controller" {
  metadata {
    name      = "nginx-ingress-controller"
    namespace = "${kubernetes_namespace.ingress_nginx.metadata.0.name}"
    labels = {
      "app.kubernetes.io/name"    = "ingress-nginx"
      "app.kubernetes.io/part-of" = "ingress-nginx"
    }
  }
  spec {
    replicas = "1"

    selector {
      match_labels = {
        "app.kubernetes.io/name"    = "ingress-nginx"
        "app.kubernetes.io/part-of" = "ingress-nginx"
      }
    }

    template {
      metadata {
        annotations = {
          "prometheus.io/port"   = "10254"
          "prometheus.io/scrape" = true
        }
        labels = {
          "app.kubernetes.io/name"    = "ingress-nginx"
          "app.kubernetes.io/part-of" = "ingress-nginx"
        }
      }

      spec {
        container {
          args = ["/nginx-ingress-controller", "--configmap=$(POD_NAMESPACE)/nginx-configuration", "--tcp-services-configmap=$(POD_NAMESPACE)/tcp-services", "--udp-services-configmap=$(POD_NAMESPACE)/udp-services", "--publish-service=$(POD_NAMESPACE)/ingress-nginx", "--annotations-prefix=nginx.ingress.kubernetes.io"]

          env {
            name = "POD_NAME"

            value_from {
              field_ref {
                api_version = "v1"
                field_path  = "metadata.name"
              }
            }
          }

          env {
            name = "POD_NAMESPACE"

            value_from {
              field_ref {
                api_version = "v1"
                field_path  = "metadata.namespace"
              }
            }
          }

          image = "quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.23.0"

          liveness_probe {
            failure_threshold = "3"

            http_get {
              path   = "/healthz"
              port   = "10254"
              scheme = "HTTP"
            }

            initial_delay_seconds = "10"
            period_seconds        = "10"
            success_threshold     = "1"
            timeout_seconds       = "10"
          }

          name = "nginx-ingress-controller"

          port {
            container_port = "80"
            name           = "http"
          }

          port {
            container_port = "443"
            name           = "https"
          }

          readiness_probe {
            failure_threshold = "3"

            http_get {
              path   = "/healthz"
              port   = "10254"
              scheme = "HTTP"
            }

            initial_delay_seconds = "0"
            period_seconds        = "10"
            success_threshold     = "1"
            timeout_seconds       = "10"
          }

          security_context {
            allow_privilege_escalation = true

            capabilities {
              add  = ["NET_BIND_SERVICE"]
              drop = ["ALL"]
            }
            run_as_user = "33"
          }

          stdin                    = false
          stdin_once               = false
          termination_message_path = "/dev/termination-log"
          tty                      = false
        }

        # Due to some weird bug, automout has to be added despite not being in the original spec https://discuss.kubernetes.io/t/nginx-ingress-install-failure/5379/5
        automount_service_account_token = true
        service_account_name = "nginx-ingress-serviceaccount"
      }
    }
  }
}

resource "kubernetes_service" "ingress-nginx" {
  metadata {
    name      = "ingress-nginx"
    namespace = "${kubernetes_namespace.ingress_nginx.metadata.0.name}"
    labels = {
      "app.kubernetes.io/name"    = "ingress-nginx"
      "app.kubernetes.io/part-of" = "ingress-nginx"
    }
  }

  spec {
    external_traffic_policy = "Local"

    port {
      name        = "http"
      port        = "80"
      protocol    = "TCP"
      target_port = "http"
    }

    port {
      name        = "https"
      port        = "443"
      protocol    = "TCP"
      target_port = "https"
    }

    selector = {
      "app.kubernetes.io/name"    = "ingress-nginx"
      "app.kubernetes.io/part-of" = "ingress-nginx"
    }

    type = "LoadBalancer"
  }
}
