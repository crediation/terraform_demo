resource "kubernetes_deployment" "metabase" {
  metadata {
    name = "metabase"
    labels = {
      app = "metabase"
    }
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
            name          = "metabase"
          }
          env {
            name = "MB_DB_USER"
            value_from {
              secret_key_ref {
                name  = "${kubernetes_secret.metabase_secrets.metadata.0.name}"
                key = "metabase_db_user"
              }
            }
          }
          # TODO add readiness and liveliness probes
          env {
            name = "MB_DB_PASS"
            value_from {
              secret_key_ref {
                name  = "${kubernetes_secret.metabase_secrets.metadata.0.name}"
                key = "metabase_db_password"
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
          command = ["\"/cloud_sql_proxy\", -instances=${var.db_instance} -credential_file=${base64decode(var.cloud_sql_credentials)} "]
        }
      }
    }
  }
}

# resource "kubernetes_service" "metabase" {
# }

# resource "kubernetes_ingress" "metabase_ingress" {

# }

resource "kubernetes_secret" "metabase_secrets" {
  metadata {
    name = "metabase-secrets"
    namespace = "${kubernetes_namespace.sandbox.metadata.0.name}"
  }

  data = {
    metabase_db_user     = "${var.metabase_db_user}"
    metabase_db_password = "${var.metabase_db_password}"
  }

  type = "Opaque"
}
