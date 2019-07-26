output "metabase_database" {
  value = "${google_sql_database.metabase_database.name}"
}
