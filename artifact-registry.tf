resource "google_artifact_registry_repository" "ghcr" {
  location      = var.region
  repository_id = "ghcr"
  description   = "Proxy to GitHub Container Registry (ghcr.io)"
  format        = "DOCKER"
  mode          = "REMOTE_REPOSITORY"
  project       = local.project_id

  remote_repository_config {
    common_repository {
      uri = "https://ghcr.io"
    }
  }
}

locals {
  is_ghcr_image           = startswith(var.image_repository, "ghcr.io/")
  ghcr_image_path         = replace(var.image_repository, "ghcr.io/", "")
  artifact_registry_image = local.is_ghcr_image ? "${var.region}-docker.pkg.dev/${local.project_id}/${google_artifact_registry_repository.ghcr.repository_id}/${local.ghcr_image_path}" : var.image_repository
}

