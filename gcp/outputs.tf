output "project_id" {
  value = "${google_project.demo_project.project_id}"
}

output "cloudsql_proxy_sa_key" {
  value = "${google_service_account_key.cloudsql_proxy_sa_key.private_key}"
}
