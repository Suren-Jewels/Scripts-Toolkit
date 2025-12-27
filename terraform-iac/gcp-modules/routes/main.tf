resource "google_compute_route" "routes" {
  count       = length(var.routes)
  name        = var.routes[count.index].name
  network     = var.vpc_self_link
  dest_range  = var.routes[count.index].destination
  next_hop_ip = var.routes[count.index].next_hop_ip
  priority    = var.routes[count.index].priority

  project = var.project_id

  tags = var.routes[count.index].tags
}
