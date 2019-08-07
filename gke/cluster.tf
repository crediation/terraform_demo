resource "google_container_cluster" "primary" {
  project = "${google_project.demo_project.project_id}"
  name     = "demo-cluster"
  location = "${var.zone}"

  remove_default_node_pool = true
  initial_node_count = 1

  master_auth {
    username = "${var.k8s_username}"
    password = "${var.k8s_password}"

    client_certificate_config {
      issue_client_certificate = false
    }
  }
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  project = "${google_project.demo_project.project_id}"
  name       = "demo-node-pool"
  location   = "${var.zone}"
  cluster    = "${google_container_cluster.primary.name}"
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "n1-standard-1"

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}

provider "kubernetes" {
  host = "${google_container_cluster.primary.endpoint}"

  client_certificate     = "${base64decode(google_container_cluster.primary.master_auth.0.client_certificate)}"
  client_key             = "${base64decode(google_container_cluster.primary.master_auth.0.client_key)}"
  cluster_ca_certificate = "${base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)}"
}

resource "kubernetes_namespace" "sandbox" {
  depends_on = ["google_container_node_pool.primary_preemptible_nodes"]
  metadata {
    name = "sandbox"
  }
}