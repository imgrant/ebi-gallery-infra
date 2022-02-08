terraform {
  required_version = ">= 1.1.2"
}

provider "digitalocean" {
  token = var.do_token
}

locals {
  k8s_cluster_name  = "k8s-${lower(digitalocean_project.active.name)}"
  db_cluster_name   = "db-${lower(digitalocean_project.active.name)}"
  database = {
    engine  = "mysql"
    version = "8"
  }
}

resource "digitalocean_project" "active" {
  name = var.do_project_name
  description = "EBI01948 technical challenge"
  environment = "Staging"
  resources = []
}

data "digitalocean_kubernetes_cluster" "primary" {
  name        = module.doks-cluster.cluster_name
  depends_on  = [module.doks-cluster]
}

module "doks-cluster" {
  source                = "./doks-cluster"
  cluster_name          = local.k8s_cluster_name
  cluster_region        = var.do_region
  cluster_version       = var.doks_cluster_version
  cluster_upgrade_day   = var.doks_cluster_auto_upgrade_day
  cluster_upgrade_time  = var.doks_cluster_auto_upgrade_time
  worker_size           = var.doks_node_size
  worker_count_min      = var.doks_nodes_min
  worker_count_max      = var.doks_nodes_max
}