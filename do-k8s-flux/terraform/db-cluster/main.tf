terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = ">= 2.16.0"
    }
  }
}

data "digitalocean_kubernetes_cluster" "primary" {
  name = var.k8s_cluster_name
}

resource "digitalocean_database_cluster" "primary" {
  name        = var.cluster_name
  region      = var.cluster_region
  engine      = var.db_engine
  version     = var.engine_version
  size        = var.node_size
  node_count  = var.node_count

  maintenance_window {
    day   = var.cluster_upgrade_day
    hour  = var.cluster_upgrade_time
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "digitalocean_database_firewall" "primary" {
  cluster_id = digitalocean_database_cluster.primary.id

  rule {
    type  = "k8s"
    value = data.digitalocean_kubernetes_cluster.primary.id
  }

  lifecycle {
    ignore_changes = [ rule ]
  }
}

data "digitalocean_database_ca" "primary" {
  cluster_id = digitalocean_database_cluster.primary.id
}
