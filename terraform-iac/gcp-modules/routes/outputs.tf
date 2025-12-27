output "route_names" {
  value = google_compute_route.routes[*].name
}

output "route_self_links" {
  value = google_compute_route.routes[*].self_link
}
