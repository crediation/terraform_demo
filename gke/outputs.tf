output "project_id" {
  value = "${google_project.credation_proj.project_id}"
}
output "host" {
  value = "${google_container_cluster.primary.endpoint}"
  sensitive = true
}
output "client_certificate" {
  value = "${google_container_cluster.primary.master_auth.0.client_certificate}"
  sensitive = true
}
output "client_key" {
  value = "${google_container_cluster.primary.master_auth.0.client_key}"
  sensitive = true
}
output "cluster_ca_certificate" {
  value = "${google_container_cluster.primary.master_auth.0.cluster_ca_certificate}"
  sensitive = true
}
output "cloud_sql_credentials" {
  value     = "${google_service_account_key.cloudsql_proxy_sa_key.private_key}"
  sensitive = true
}