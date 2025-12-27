resource "google_logging_project_sink" "this" {
  name        = var.sink_name
  project     = var.project_id
  destination = var.destination
  filter      = var.filter

  unique_writer_identity = true
}

resource "google_monitoring_alert_policy" "alerts" {
  count   = length(var.alert_policies)
  project = var.project_id

  display_name = var.alert_policies[count.index].display_name
  combiner     = var.alert_policies[count.index].combiner

  conditions {
    display_name = var.alert_policies[count.index].condition.display_name

    condition_threshold {
      filter          = var.alert_policies[count.index].condition.filter
      duration        = var.alert_policies[count.index].condition.duration
      comparison      = var.alert_policies[count.index].condition.comparison
      threshold_value = var.alert_policies[count.index].condition.threshold_value

      aggregations {
        alignment_period     = var.alert_policies[count.index].condition.alignment_period
        per_series_aligner   = var.alert_policies[count.index].condition.per_series_aligner
      }
    }
  }

  notification_channels = var.alert_policies[count.index].notification_channels
}
