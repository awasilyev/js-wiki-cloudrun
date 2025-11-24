locals {
  secrets = {
    DB_PASS                    = random_password.db_password.result
    WIKI_STORAGE_S3_ACCESS_KEY = google_storage_hmac_key.key.access_id
    WIKI_STORAGE_S3_SECRET_KEY = google_storage_hmac_key.key.secret
  }
}


resource "google_secret_manager_secret" "secret" {
  for_each  = local.secrets
  secret_id = each.key
  project   = local.project_id
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "secret" {
  for_each    = local.secrets
  secret      = google_secret_manager_secret.secret[each.key].id
  secret_data = each.value
}

resource "google_secret_manager_secret_iam_member" "secret" {
  for_each  = local.secrets
  secret_id = google_secret_manager_secret.secret[each.key].id
  role      = "roles/secretmanager.secretAccessor"
  member    = google_service_account.cloudrun.member
}