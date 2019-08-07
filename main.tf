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
module "gcp" {
  source = "./gcp"

  project      = "${var.project}"
  zone         = "${var.zone}"

  org_id       = "${var.org_id}"
  billing_id   = "${var.billing_id}"
}

module "gke" {
  source       = "./gke"

  project_id            = "${module.gcp.project_id}"
  cloudsql_proxy_sa_key = "${module.gcp.cloudsql_proxy_sa_key}"

  zone         = "${var.zone}"
  k8s_username = "${var.k8s_username}"
  k8s_password = "${var.k8s_password}"
  
  db_instance_connection_name = "${module.cloudsql.db_instance_connection_name}"
  metabase_db_name            = "${module.cloudsql.metabase_db_name}"
  metabase_db_user            = "${var.metabase_db_user}"
  metabase_db_password        = "${var.metabase_db_password}"
}

module "cloudsql" {
  source = "./cloudsql"

  project_id = "${module.gcp.project_id}"
  region     = "${var.region}"
  
  metabase_db_user     = "${var.metabase_db_user}"
  metabase_db_password = "${var.metabase_db_password}"
}

output "loadbalancer_ip_address" {
  value = "${module.gke.loadbalancer_ip_address}"
}
output "metabase_host_name" {
  value = "${module.gke.metabase_hostname}"
}