output "subnet_ids" {
  value = google_compute_subnetwork.subnets[*].id
}

output "subnet_self_links" {
  value = google_compute_subnetwork.subnets[*].self_link
}

output "subnet_names" {
  value = google_compute_subnetwork.subnets[*].name
}
