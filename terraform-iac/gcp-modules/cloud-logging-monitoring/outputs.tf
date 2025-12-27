output "sink_writer_identity" {
  value = google_logging_project_sink.this.writer_identity
}

output "alert_policy_ids" {
  value = google_monitoring_alert_policy.alerts[*].id
}
