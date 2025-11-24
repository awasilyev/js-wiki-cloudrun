resource "google_storage_bucket" "wiki" {
  name                        = "og-hiring-assessment-wiki"
  location                    = var.region
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true

  soft_delete_policy {
    retention_duration_seconds = 0 # special requirement for my test gcp project
  }
}

resource "google_storage_bucket_iam_member" "wiki" {
  bucket = google_storage_bucket.wiki.name
  role   = "roles/storage.objectUser"
  member = google_service_account.cloudrun.member
}

resource "google_storage_hmac_key" "key" {
  service_account_email = google_service_account.cloudrun.email
}
