resource "google_compute_region_autoscaler" "this" {
  name    = var.name
  region  = var.region
  project = var.project_id

  target = var.instance_group_manager

  autoscaling_policy {
    min_replicas             = var.min_replicas
    max_replicas             = var.max_replicas
    cooldown_period          = var.cooldown_period
    mode                     = var.mode
    cpu_utilization {
      target = var.cpu_target
    }
  }
}
