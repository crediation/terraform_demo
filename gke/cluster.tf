# resource "google_container_cluster" "primary" {
#   name     = "demo-cluster"
#   location = "${var.region}"

#   remove_default_node_pool = true
#   initial_node_count = 1

#   master_auth {
#     username = "${var.k8s_username}"
#     password = "${var.k8s_password}"

#     client_certificate_config {
#       issue_client_certificate = false
#     }
#   }
# }

# resource "google_container_node_pool" "primary_preemptible_nodes" {
#   name       = "demo-node-pool"
#   location   = "${var.region}"
#   cluster    = "${google_container_cluster.primary.name}"
#   node_count = 1

#   node_config {
#     preemptible  = true
#     machine_type = "n1-standard-1"

#     metadata = {
#       disable-legacy-endpoints = "true"
#     }

#     oauth_scopes = [
#       "https://www.googleapis.com/auth/logging.write",
#       "https://www.googleapis.com/auth/monitoring",
#     ]
#   }
# }