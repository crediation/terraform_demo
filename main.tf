# variables
variable project {}
variable region {}
variable zone {}
variable billing_id {}
variable org_id {}
variable k8s_username {}
variable k8s_password {}
variable metabase_db_user {}
variable metabase_db_password {}


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

  project_id           = "${module.gke.project_id}"
  region               = "${var.region}"
  metabase_db_user     = "${var.metabase_db_user}"
  metabase_db_password = "${var.metabase_db_password}"
}

module "k8s" {
  source = "./k8s"

  project_id             = "${module.gke.project_id}"
  host                   = "${module.gke.host}"
  client_certificate     = "${module.gke.client_certificate}"
  client_key             = "${module.gke.client_key}"
  cluster_ca_certificate = "${module.gke.cluster_ca_certificate}"
  cloudsql_credentials   = "${module.gke.cloudsql_credentials}"

  db_instance_connection_name = "${module.cloudsql.db_instance_connection_name}"
  metabase_db_name            = "${module.cloudsql.metabase_db_name}"
  metabase_db_user            = "${var.metabase_db_user}"
  metabase_db_password        = "${var.metabase_db_password}"
}