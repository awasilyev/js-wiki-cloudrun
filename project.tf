module "project" {
  count  = var.existing_project_id == null ? 1 : 0
  source = "terraform-google-modules/project-factory/google"
  providers = {
    google      = google.noproject
    google-beta = google-beta.noproject
  }
  version                     = "18.2.0"
  name                        = var.project
  org_id                      = var.organization_id
  domain                      = var.domain
  billing_account             = var.billing_account
  activate_apis               = var.activate_apis
  disable_services_on_destroy = false
  disable_dependent_services  = false
  auto_create_network         = true
}

locals {
  project_id = var.existing_project_id == null ? module.project[0].project_id : var.existing_project_id
}