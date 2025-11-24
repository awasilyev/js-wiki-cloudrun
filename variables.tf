variable "project" {
  type    = string
  default = "wiki"
}

variable "existing_project_id" {
  type    = string
  default = null
}

variable "organization_id" {
  type    = string
  default = null
}

variable "billing_account" {
  type    = string
  default = null
}

variable "region" {
  type    = string
  default = "us-east4"
}

variable "image_repository" {
  type    = string
  default = "ghcr.io/requarks/wiki"
}

variable "image_tag" {
  type    = string
  default = "2"
}

variable "activate_apis" {
  type = list(string)
  default = [
    "cloudrun.googleapis.com",
    "secretmanager.googleapis.com",
    "logging.googleapis.com",
    "compute.googleapis.com",
    "sqladmin.googleapis.com",
    "servicenetworking.googleapis.com",
    "artifactregistry.googleapis.com"
  ]
}

variable "domain" {
  type = string
}