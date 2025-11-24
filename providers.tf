

provider "google" {
  project = local.project_id
  region  = var.region
}

provider "google-beta" {
  project = local.project_id
  region  = var.region
}

provider "google" {
  alias  = "noproject"
  region = var.region
}

provider "google-beta" {
  alias  = "noproject"
  region = var.region
}