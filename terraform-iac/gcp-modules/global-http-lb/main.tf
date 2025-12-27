resource "google_compute_global_address" "lb_ip" {
  name    = "${var.name}-ip"
  project = var.project_id
}

resource "google_compute_backend_service" "this" {
  name                  = "${var.name}-backend"
  project               = var.project_id
  protocol              = "HTTP"
  port_name             = var.port_name
  timeout_sec           = var.timeout_sec
  load_balancing_scheme = "EXTERNAL"

  backend {
    group = var.instance_group
  }

  health_checks = [google_compute_health_check.this.self_link]
}

resource "google_compute_health_check" "this" {
  name    = "${var.name}-hc"
  project = var.project_id

  http_health_check {
    port = var.health_check_port
  }
}

resource "google_compute_url_map" "this" {
  name            = "${var.name}-url-map"
  project         = var.project_id
  default_service = google_compute_backend_service.this.self_link
}

resource "google_compute_target_http_proxy" "this" {
  name    = "${var.name}-proxy"
  project = var.project_id
  url_map = google_compute_url_map.this.self_link
}

resource "google_compute_global_forwarding_rule" "this" {
  name                  = "${var.name}-fw-rule"
  project               = var.project_id
  target                = google_compute_target_http_proxy.this.self_link
  port_range            = "80"
  ip_address            = google_compute_global_address.lb_ip.address
  load_balancing_scheme = "EXTERNAL"
}
