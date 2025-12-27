resource "google_compute_instance_template" "this" {
  name_prefix  = "${var.name}-tpl-"
  project      = var.project_id
  machine_type = var.machine_type
  region       = var.region

  disk {
    source_image = var.image
    auto_delete  = true
    boot         = true
    disk_size_gb = var.disk_size_gb
    disk_type    = var.disk_type
  }

  network_interface {
    subnetwork = var.subnet_self_link

    dynamic "access_config" {
      for_each = var.assign_public_ip ? [1] : []
      content {}
    }
  }

  metadata = var.metadata
  labels   = var.labels
  tags     = var.tags
}

resource "google_compute_region_instance_group_manager" "this" {
  name               = var.name
  project            = var.project_id
  region             = var.region
  base_instance_name = var.name

  version {
    instance_template = google_compute_instance_template.this.self_link
  }

  target_size = var.target_size

  auto_healing_policies {
    health_check      = var.health_check
    initial_delay_sec = var.initial_delay_sec
  }

  depends_on = [google_compute_instance_template.this]
}
