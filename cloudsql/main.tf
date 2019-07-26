resource "google_sql_database_instance" "demo_instance" {
  project          = "${var.project_id}"
  name             = "demo-db"
  region           = "${var.region}"
  database_version = "POSTGRES_9_6"

  settings {
    tier              = "db-f1-micro"
    disk_autoresize   = true

    backup_configuration {
      enabled            = true
      start_time         = "00:00"
    }
    # TODO define maintaince window
  }
}
# TODO consider creating a replica instance for backup.

resource "google_sql_user" "metabase_user" {
  project  = "${var.project_id}"
  instance = "${google_sql_database_instance.demo_instance.name}"
  name     = "${var.metabase_db_user}"
  password = "${var.metabase_db_password}"
}

resource "google_sql_database" "metabase_database" {
  project   = "${var.project_id}"
  name      = "metabase"
  instance  = "${google_sql_database_instance.demo_instance.name}"
  # TODO make database highly available
}