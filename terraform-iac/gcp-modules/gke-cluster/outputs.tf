output "cluster_name" {
  value = google_container_cluster.this.name
}

output "cluster_endpoint" {
  value = google_container_cluster.this.endpoint
}

output "node_pool_name" {
  value = google_container_node_pool.primary.name
}
