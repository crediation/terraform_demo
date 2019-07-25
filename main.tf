# variables
variable project {}
variable region {}
variable billing_id {}
variable org_id {}
variable k8s_username {}
variable k8s_password {}


# modules
module "gke" {
  source       = "./gke"

  project      = "${var.project}"
  region       = "${var.region}"

  org_id       = "${var.org_id}"
  billing_id   = "${var.billing_id}"

  k8s_username = "${var.k8s_username}"
  k8s_password = "${var.k8s_password}"
}
