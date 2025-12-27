resource "google_compute_address" "lb_ip" {
  name    = "${var.name}-ip"
  region  = var.region
  project = var.project_id
}

resource "google_compute_health_check" "this" {
  name    = "${var.name}-hc"
  project = var.project_id

  tcp_health_check {
    port = var.health_check_port
  }
}

resource "google_compute_backend_service" "this" {
  name                  = "${var.name}-backend"
  project               = var.project_id
  protocol              = "TCP"
  timeout_sec           = var.timeout_sec
  load_balancing_scheme = "EXTERNAL"

  backend {
    group = var.instance_group
  }

  health_checks = [google_compute_health_check.this.self_link]
}

resource "google_compute_forwarding_rule" "this" {
  name                  = "${var.name}-fw-rule"
  region                = var.region
  project               = var.project_id
  load_balancing_scheme = "EXTERNAL"
  ip_address            = google_compute_address.lb_ip.address
  port_range            = var.port_range
  backend_service       = google_compute_backend_service.this.self_link
}
