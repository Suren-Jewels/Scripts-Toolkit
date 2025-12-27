output "psc_ip" {
  value = google_compute_global_address.psc_ip.address
}

output "psc_forwarding_rule" {
  value = google_compute_forwarding_rule.psc_endpoint.self_link
}
