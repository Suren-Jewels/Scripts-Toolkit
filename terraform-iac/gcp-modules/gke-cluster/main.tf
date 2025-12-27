resource "google_container_cluster" "this" {
  name     = var.name
  project  = var.project_id
  location = var.location

  network    = var.vpc_self_link
  subnetwork = var.subnet_self_link

  remove_default_node_pool = true
  initial_node_count       = 1

  ip_allocation_policy {}

  release_channel {
    channel = var.release_channel
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  labels = var.labels
}

resource "google_container_node_pool" "primary" {
  name       = "${var.name}-nodepool"
  project    = var.project_id
  location   = var.location
  cluster    = google_container_cluster.this.name

  node_count = var.node_count

  node_config {
    machine_type = var.machine_type
    disk_size_gb = var.disk_size_gb
    disk_type    = var.disk_type
    oauth_scopes = var.oauth_scopes
    labels       = var.labels
    tags         = var.tags
  }
}
