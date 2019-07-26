# variables
variable project {}
variable region {}
variable zone {}
variable billing_id {}
variable org_id {}
variable k8s_username {}
variable k8s_password {}
variable metabase_user {}
variable metabase_password {}


# modules
module "gke" {
  source       = "./gke"

  project      = "${var.project}"
  zone         = "${var.zone}"

  org_id       = "${var.org_id}"
  billing_id   = "${var.billing_id}"

  k8s_username = "${var.k8s_username}"
  k8s_password = "${var.k8s_password}"
}

module "cloudsql" {
  source = "./cloudsql"

  project_id        = "${module.gke.project_id}"
  region            = "${var.region}"
  metabase_user     = "${var.metabase_user}"
  metabase_password = "${var.metabase_password}"
}
