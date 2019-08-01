resource "kubernetes_deployment" "metabase" {
  metadata {
    name = "metabase"
    labels = {
      app = "metabase"
    }
    namespace = "${kubernetes_namespace.sandbox.metadata.0.name}"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "metabase"
      }
    }
    template {
      metadata {
        labels = {
          app = "metabase"
        }
      }
      spec {
        container {
          name  = "metabase"
          image = "metabase/metabase"
          port {
            container_port = 3000
            name           = "metabase"
          }
          env {
            name = "MB_DB_USER"
            value_from {
              secret_key_ref {
                name = "${kubernetes_secret.metabase_secrets.metadata.0.name}"
                key  = "metabase_db_user"
              }
            }
          }
          # TODO add readiness and liveliness probes
          env {
            name = "MB_DB_PASS"
            value_from {
              secret_key_ref {
                name = "${kubernetes_secret.metabase_secrets.metadata.0.name}"
                key  = "metabase_db_password"
              }
            }
          }
          env {
            name  = "MB_DB_HOST"
            value = "localhost"
          }
          env {
            name  = "MB_DB_DBNAME"
            value = "${var.metabase_db_name}"
          }
          env {
            name  = "MB_DB_TYPE"
            value = "postgres"
          }
          env {
            name  = "MB_DB_PORT"
            value = "5432"
          }
        }
        container {
          name    = "cloudsql"
          image   = "gcr.io/cloudsql-docker/gce-proxy:1.14"
          command = ["/cloud_sql_proxy", "-instances=${var.db_instance_connection_name}=tcp:5432", "-credential_file=/secrets/cloudsql/credentials.json"]
          volume_mount {
            name       = "cloudsql-instance-credentials"
            mount_path = "/secrets/cloudsql"
            read_only  = true
          }
        }
        volume {
          name = "cloudsql-instance-credentials"
          secret {
            secret_name = "cloudsql-instance-credentials"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "metabase" {
  metadata {
    labels = {
      app = "metabase"
    }

    name      = "metabase"
    namespace = "${kubernetes_namespace.sandbox.metadata.0.name}"
  }

  spec {
    external_traffic_policy = "Cluster"

    port {
      port        = "3000"
      protocol    = "TCP"
      target_port = "3000"
    }
    selector = {
      app = "metabase"
    }

    type = "NodePort"
  }
}

resource "kubernetes_ingress" "metabase_ingress" {
  metadata {
    name      = "metabase-ingress"
    namespace = "${kubernetes_namespace.sandbox.metadata.0.name}"
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
    }
  }
  spec {
    rule {
      host = "metabase.crediation.io"
      http {
        path {
          path = "/"
          backend {
            service_name = "metabase"
            service_port = 3000
          }
        }
      }

    }
  }
}

resource "kubernetes_secret" "metabase_secrets" {
  metadata {
    name      = "metabase-secrets"
    namespace = "${kubernetes_namespace.sandbox.metadata.0.name}"
  }

  data = {
    metabase_db_user     = "${var.metabase_db_user}"
    metabase_db_password = "${var.metabase_db_password}"
  }

  type = "Opaque"
}

resource "kubernetes_secret" "cloudsql-instance-credentials" {
  metadata {
    name      = "cloudsql-instance-credentials"
    namespace = "${kubernetes_namespace.sandbox.metadata.0.name}"
  }
  data = {
    "credentials.json" = "${base64decode(google_service_account_key.cloudsql_proxy_sa_key.private_key)}"
  }
}
