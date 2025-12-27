resource "google_compute_vpn_gateway" "this" {
  name    = var.name
  network = var.vpc_self_link
  region  = var.region

  project = var.project_id

  labels = var.labels
}

resource "google_compute_address" "vpn_static_ip" {
  name   = "${var.name}-ip"
  region = var.region

  project = var.project_id
}

resource "google_compute_vpn_tunnel" "tunnels" {
  count                 = length(var.tunnels)
  name                  = var.tunnels[count.index].name
  region                = var.region
  target_vpn_gateway    = google_compute_vpn_gateway.this.id
  peer_ip               = var.tunnels[count.index].peer_ip
  shared_secret         = var.tunnels[count.index].shared_secret
  ike_version           = var.tunnels[count.index].ike_version
  local_traffic_selector  = var.tunnels[count.index].local_traffic_selector
  remote_traffic_selector = var.tunnels[count.index].remote_traffic_selector

  project = var.project_id

  depends_on = [google_compute_address.vpn_static_ip]
}
