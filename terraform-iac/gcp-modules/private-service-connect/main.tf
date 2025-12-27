resource "google_compute_global_address" "psc_ip" {
  name         = "${var.name}-psc-ip"
  purpose      = "VPC_PEERING"
  address_type = "INTERNAL"
  network      = var.vpc_self_link

  project = var.project_id

  labels = var.labels
}

resource "google_compute_forwarding_rule" "psc_endpoint" {
  name                  = "${var.name}-psc-endpoint"
  load_balancing_scheme = "INTERNAL"
  target                = var.target_service
  network               = var.vpc_self_link
  subnetwork            = var.subnet_self_link
  ip_address            = google_compute_global_address.psc_ip.address
  ports                 = var.ports

  project = var.project_id

  labels = var.labels
}
