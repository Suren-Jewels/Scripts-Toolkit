resource "google_compute_subnetwork" "subnets" {
  count                    = length(var.subnets)
  name                     = var.subnets[count.index].name
  ip_cidr_range            = var.subnets[count.index].cidr
  region                   = var.subnets[count.index].region
  network                  = var.vpc_self_link
  private_ip_google_access = var.subnets[count.index].private_google_access

  project = var.project_id

  labels = var.labels
}
