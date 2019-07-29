output "metabase_db_name" {
  value = "${google_sql_database.metabase_database.name}"
}

output "db_instance_connection_name" {
  value = "${google_sql_database_instance.demo_instance.connection_name}"
}
