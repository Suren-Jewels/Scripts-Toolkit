resource "google_compute_router" "this" {
  name    = "${var.name}-router"
  region  = var.region
  network = var.vpc_self_link

  project = var.project_id

  labels = var.labels
}

resource "google_compute_router_nat" "this" {
  name                               = "${var.name}-nat"
  router                             = google_compute_router.this.name
  region                             = var.region
  nat_ip_allocate_option             = var.allocate_external_ips ? "AUTO_ONLY" : "MANUAL_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  project = var.project_id

  dynamic "subnetwork" {
    for_each = var.subnet_self_links
    content {
      name                    = subnetwork.value
      source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
    }
  }

  labels = var.labels
}
