resource "google_compute_global_address" "private_service_range" {
  provider      = google-beta
  project       = local.project_id
  name          = "private-service-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = "projects/${local.project_id}/global/networks/default"
}

resource "google_service_networking_connection" "private_service_access" {
  provider                = google-beta
  network                 = "projects/${local.project_id}/global/networks/default"
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_service_range.name]
}

resource "google_sql_database_instance" "wiki" {
  name             = local.cloudrun_name
  database_version = "POSTGRES_15"
  region           = var.region
  project          = local.project_id

  depends_on = [google_service_networking_connection.private_service_access]

  settings {
    tier              = "db-f1-micro"
    availability_type = "ZONAL"
    disk_autoresize   = true
    disk_size         = 10
    disk_type         = "PD_SSD"

    ip_configuration {
      ipv4_enabled    = false
      private_network = "projects/${local.project_id}/global/networks/default"
    }

    # backup_configuration {
    #   enabled                        = true
    #   start_time                     = "03:00"
    #   point_in_time_recovery_enabled = true
    #   transaction_log_retention_days  = 7
    # }
  }

  deletion_protection = false
}

resource "google_sql_database" "wiki" {
  name     = local.cloudrun_name
  instance = google_sql_database_instance.wiki.name
  project  = local.project_id
}

resource "google_sql_user" "wiki" {
  name     = local.cloudrun_name
  instance = google_sql_database_instance.wiki.name
  password = random_password.db_password.result
  project  = local.project_id
}

resource "random_password" "db_password" {
  length  = 16
  special = true
}
