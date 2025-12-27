resource "google_artifact_registry_repository" "this" {
  repository_id = var.name
  project       = var.project_id
  location      = var.location
  format        = var.format

  description = var.description
  labels      = var.labels
}
