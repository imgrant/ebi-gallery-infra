terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = ">= 2.16.0"
    }
  }
}

data "digitalocean_kubernetes_versions" "current" {
  version_prefix = var.cluster_version
}

resource "digitalocean_kubernetes_cluster" "primary" {
  name    = var.cluster_name
  region  = var.cluster_region
  version = data.digitalocean_kubernetes_versions.current.latest_version
  auto_upgrade = true

  maintenance_policy {
    day = var.cluster_upgrade_day
    start_time = var.cluster_upgrade_time
  }
  
  node_pool {
    name        = "default"
    size        = var.worker_size
    auto_scale  = true
    min_nodes   = var.worker_count_min
    max_nodes   = var.worker_count_max
  }
}
