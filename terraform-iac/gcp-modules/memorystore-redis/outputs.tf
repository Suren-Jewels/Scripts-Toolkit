output "redis_host" {
  value = google_redis_instance.this.host
}

output "redis_port" {
  value = google_redis_instance.this.port
}

output "redis_name" {
  value = google_redis_instance.this.name
}
