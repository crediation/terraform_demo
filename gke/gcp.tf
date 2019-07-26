provider "google" {
  project     = "${var.project}"
  region      = "${var.region}"
}

resource "google_project" "credation_proj" {
  name            = "${var.project}"
  project_id      = "${var.project}-id"
  org_id          = "${var.org_id}"
  billing_account = "${var.billing_id}"
}

resource "google_project_services" "crediation_services" {
  project = "${google_project.credation_proj.project_id}"
  services   = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "oslogin.googleapis.com",
    "pubsub.googleapis.com",
    ]
}

# resource "google_service_account" "crediation_test_sa" {
#   account_id   = "crediation-test-sa"
#   display_name = "crediation test sa"
# }

# resource "google_service_account_iam_member" "crediation_test_sa_iam" {
#   service_account_id = "${google_service_account.crediation_test_sa.account_id}"
#   role               = "roles/iam.serviceAccountUser"
#   member             = "serviceAccount:${google_service_account.crediation_test_sa.email}"
# }
