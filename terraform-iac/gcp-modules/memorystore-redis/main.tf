resource "google_redis_instance" "this" {
  name           = var.name
  project        = var.project_id
  region         = var.region
  tier           = var.tier
  memory_size_gb = var.memory_size_gb

  authorized_network = var.vpc_self_link

  redis_version = var.redis_version

  transit_encryption_mode = var.transit_encryption_mode

  labels = var.labels
}
