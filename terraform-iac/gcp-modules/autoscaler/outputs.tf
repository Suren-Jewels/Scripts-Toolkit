output "autoscaler_self_link" {
  value = google_compute_region_autoscaler.this.self_link
}

output "autoscaler_name" {
  value = google_compute_region_autoscaler.this.name
}
