output "nat_name" {
  value = google_compute_router_nat.this.name
}

output "router_name" {
  value = google_compute_router.this.name
}
