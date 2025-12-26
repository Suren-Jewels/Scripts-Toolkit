resource "azurerm_kubernetes_cluster" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix

  kubernetes_version = var.kubernetes_version

  default_node_pool {
    name                = var.node_pool.name
    vm_size             = var.node_pool.vm_size
    node_count          = var.node_pool.node_count
    os_disk_size_gb     = var.node_pool.os_disk_size_gb
    vnet_subnet_id      = var.node_pool.subnet_id
    enable_auto_scaling = var.node_pool.enable_auto_scaling
    min_count           = var.node_pool.min_count
    max_count           = var.node_pool.max_count
  }

  identity {
    type = var.identity_type
  }

  network_profile {
    network_plugin     = var.network_plugin
    load_balancer_sku  = var.load_balancer_sku
    dns_service_ip     = var.dns_service_ip
    service_cidr       = var.service_cidr
    docker_bridge_cidr = var.docker_bridge_cidr
  }

  tags = var.tags
}

resource "azurerm_kubernetes_cluster_node_pool" "extra_pools" {
  count                = length(var.additional_node_pools)
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  name                 = var.additional_node_pools[count.index].name
  vm_size              = var.additional_node_pools[count.index].vm_size
  node_count           = var.additional_node_pools[count.index].node_count
  vnet_subnet_id       = var.additional_node_pools[count.index].subnet_id
  os_disk_size_gb      = var.additional_node_pools[count.index].os_disk_size_gb
  enable_auto_scaling  = var.additional_node_pools[count.index].enable_auto_scaling
  min_count            = var.additional_node_pools[count.index].min_count
  max_count            = var.additional_node_pools[count.index].max_count
}
