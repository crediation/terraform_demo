output "metabase_db_name" {
  value = "${google_sql_database.metabase_database.name}"
}

output "database_instance" {
  value = "${google_sql_database_instance.demo_instance.name}"
}
