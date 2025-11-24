locals {
  cloudrun_name = "wiki"
  cloudrun_roles = toset([
    "roles/secretmanager.secretAccessor",
    "roles/logging.logWriter",
    "roles/cloudsql.client"
  ])

  cloudrun_env_vars = {
    # DB_TYPE = "sqlite"
    # DB_PATH = "/tmp/wiki.db"
    DB_TYPE                  = "postgres"
    DB_HOST                  = "/cloudsql/${google_sql_database_instance.wiki.connection_name}"
    DB_PORT                  = "5432"
    DB_NAME                  = google_sql_database.wiki.name
    DB_USER                  = google_sql_user.wiki.name
    HA_ACTIVE                = "1"
    WIKI_STORAGE_TYPE        = "s3"
    WIKI_STORAGE_S3_BUCKET   = google_storage_bucket.wiki.name
    WIKI_STORAGE_S3_ENDPOINT = "https://storage.googleapis.com"
    LOG_LEVEL                = "trace"
  }
}

resource "google_project_iam_member" "cloudrun" {
  for_each = local.cloudrun_roles
  project  = local.project_id
  role     = each.key
  member   = google_service_account.cloudrun.member
}

resource "google_service_account" "cloudrun" {
  account_id   = "${local.cloudrun_name}-sa"
  display_name = local.cloudrun_name
}

resource "google_cloud_run_v2_service" "wiki" {
  name                = local.cloudrun_name
  location            = var.region
  project             = local.project_id
  deletion_protection = false

  ingress = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"

  template {
    service_account = google_service_account.cloudrun.email

    vpc_access {
      egress = "PRIVATE_RANGES_ONLY"
      network_interfaces {
        network    = "projects/${local.project_id}/global/networks/default"
        subnetwork = "projects/${local.project_id}/regions/${var.region}/subnetworks/default"
        tags       = []
      }
    }

    volumes {
      name = "cloudsql"
      cloud_sql_instance {
        instances = [google_sql_database_instance.wiki.connection_name]
      }
    }

    containers {
      image = "${local.artifact_registry_image}:${var.image_tag}"

      ports {
        container_port = 3000
      }

      dynamic "env" {
        for_each = local.cloudrun_env_vars
        content {
          name  = env.key
          value = env.value
        }
      }

      dynamic "env" {
        for_each = local.secrets
        content {
          name = env.key
          value_source {
            secret_key_ref {
              secret  = google_secret_manager_secret.secret[env.key].id
              version = "latest"
            }
          }
        }
      }

      volume_mounts {
        name       = "cloudsql"
        mount_path = "/cloudsql"
      }

      resources {
        limits = {
          cpu    = "2"
          memory = "2Gi"
        }
      }
    }

    scaling {
      min_instance_count = 0
      max_instance_count = 10
    }
  }

  traffic {
    percent = 100
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
  }

  timeouts {
    create = "1m"
    update = "1m"
    delete = "1m"
  }
}

resource "google_compute_region_network_endpoint_group" "wiki" {
  name                  = local.cloudrun_name
  network_endpoint_type = "SERVERLESS"
  region                = var.region
  project               = local.project_id

  cloud_run {
    service = google_cloud_run_v2_service.wiki.name
  }
}

resource "google_cloud_run_v2_service_iam_member" "public" {
  project  = local.project_id
  location = var.region
  name     = google_cloud_run_v2_service.wiki.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}