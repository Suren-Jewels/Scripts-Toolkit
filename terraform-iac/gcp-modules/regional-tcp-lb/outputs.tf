output "lb_ip" {
  value = google_compute_address.lb_ip.address
}

output "forwarding_rule" {
  value = google_compute_forwarding_rule.this.self_link
}

output "backend_service" {
  value = google_compute_backend_service.this.self_link
}
