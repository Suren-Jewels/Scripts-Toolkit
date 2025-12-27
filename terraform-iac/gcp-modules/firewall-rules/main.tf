resource "google_compute_firewall" "rules" {
  count       = length(var.rules)
  name        = var.rules[count.index].name
  network     = var.vpc_self_link
  direction   = var.rules[count.index].direction
  priority    = var.rules[count.index].priority
  disabled    = var.rules[count.index].disabled

  project = var.project_id

  allow {
    protocol = var.rules[count.index].allow.protocol
    ports    = var.rules[count.index].allow.ports
  }

  source_ranges      = var.rules[count.index].source_ranges
  destination_ranges = var.rules[count.index].destination_ranges
  target_tags        = var.rules[count.index].target_tags
  source_tags        = var.rules[count.index].source_tags

  labels = var.labels
}
