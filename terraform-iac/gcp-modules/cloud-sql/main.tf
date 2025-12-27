resource "google_sql_database_instance" "this" {
  name             = var.name
  project          = var.project_id
  region           = var.region
  database_version = var.database_version

  settings {
    tier              = var.tier
    availability_type = var.availability_type

    ip_configuration {
      ipv4_enabled    = var.public_ip
      private_network = var.private_network
      require_ssl     = var.require_ssl
    }

    backup_configuration {
      enabled            = var.backup_enabled
      start_time         = var.backup_start_time
      point_in_time_recovery_enabled = var.point_in_time_recovery
    }

    disk_size          = var.disk_size_gb
    disk_type          = var.disk_type
    disk_autoresize    = var.disk_autoresize
  }

  deletion_protection = var.deletion_protection

  labels = var.labels
}

resource "google_sql_user" "default" {
  name     = var.db_user
  instance = google_sql_database_instance.this.name
  project  = var.project_id
  password = var.db_password
}

resource "google_sql_database" "default" {
  name     = var.db_name
  instance = google_sql_database_instance.this.name
  project  = var.project_id
}
