provider "google" {
  project     = "${var.project}"
  zone        = "${var.zone}"
}

resource "google_project" "demo_project" {
  name            = "${var.project}"
  project_id      = "${var.project}-id"
  org_id          = "${var.org_id}"
  billing_account = "${var.billing_id}"
}

resource "google_project_services" "demo_services" {
  project = "${google_project.demo_project.project_id}"
  services   = [
    "bigquery-json.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "containerregistry.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "oslogin.googleapis.com",
    "pubsub.googleapis.com",
    "storage-api.googleapis.com",
    "sqladmin.googleapis.com",
    ]
}

resource "google_service_account" "cloudsql_proxy_sa" {
  project = "${google_project.demo_project.project_id}"
  account_id   = "cloudsql-proxy-sa"
  display_name = "cloud_sql proxy service account"
}

# google_service_account_iam_member cannot be used here. See https://github.com/terraform-providers/terraform-provider-google/issues/1225
resource "google_project_iam_member" "cloudsql_proxy_sa_iam" {
  project = "${google_project.demo_project.project_id}"
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.cloudsql_proxy_sa.email}"
}

resource "google_service_account_key" "cloudsql_proxy_sa_key" {
  service_account_id = "${google_service_account.cloudsql_proxy_sa.name}"
  public_key_type = "TYPE_X509_PEM_FILE"
}