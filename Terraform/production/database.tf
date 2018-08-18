resource "random_id" "db-name" {
  byte_length = 8
}

resource "random_id" "lenken-db-user" {
  byte_length = 8
}

resource "random_id" "lenken-db-user-password" {
  byte_length = 16
}

// Create postgres database instance
resource "google_sql_database_instance" "lenken-database-instance" {
  region = "${var.region}"
  database_version = "POSTGRES_9_6"
  name = "${var.env_name}-lenken-database3-instance-${replace(lower(random_id.db-name.b64), "_", "-")}"
  project = "${var.project_id}"

  settings {
    tier = "${var.db_instance_tier}"
    disk_autoresize = true
    ip_configuration = {
      ipv4_enabled = true

      authorized_networks = [{
        name = "all"
        value = "0.0.0.0/0"
      }]
    }

    backup_configuration {
      binary_log_enabled = true
      enabled = true
      start_time = "${var.db_backup_start_time}"
    }
  }
}

// Create database
resource "google_sql_database" "lenken-database" {
  name = "${var.env_name}-lenken-database"
  instance = "${google_sql_database_instance.lenken-database-instance.name}"
  charset = "UTF8"
  collation = "en_US.UTF8"
}

// Create database user
resource "google_sql_user" "lenken-database-user" {
  name = "${random_id.lenken-db-user.b64}"
  password = "${random_id.lenken-db-user-password.b64}"
  instance = "${google_sql_database_instance.lenken-database-instance.name}"
  host = ""
}