resource "google_storage_bucket" "this" {
  name                        = var.name
  project                     = var.project_id
  location                    = var.location
  storage_class               = var.storage_class
  uniform_bucket_level_access = var.uniform_access

  versioning {
    enabled = var.versioning
  }

  lifecycle_rule {
    action {
      type = var.lifecycle_action
    }
    condition {
      age = var.lifecycle_age
    }
  }

  labels = var.labels
}
