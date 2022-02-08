terraform {
  required_version = ">= 1.1.2"
}

provider "digitalocean" {
  token = var.do_token
}

provider "github" {
  owner = var.github_owner
  token = var.github_token
}

provider "flux" {}

provider "kubectl" {
  host             = data.digitalocean_kubernetes_cluster.primary.endpoint
  token            = data.digitalocean_kubernetes_cluster.primary.kube_config[0].token
  cluster_ca_certificate = base64decode(
    data.digitalocean_kubernetes_cluster.primary.kube_config[0].cluster_ca_certificate
  )
  load_config_file = false
}

provider "kubernetes" {
  host             = data.digitalocean_kubernetes_cluster.primary.endpoint
  token            = data.digitalocean_kubernetes_cluster.primary.kube_config[0].token
  cluster_ca_certificate = base64decode(
    data.digitalocean_kubernetes_cluster.primary.kube_config[0].cluster_ca_certificate
  )
}

provider "helm" {
  kubernetes {
    host  = data.digitalocean_kubernetes_cluster.primary.endpoint
    token = data.digitalocean_kubernetes_cluster.primary.kube_config[0].token
    cluster_ca_certificate = base64decode(
      data.digitalocean_kubernetes_cluster.primary.kube_config[0].cluster_ca_certificate
    )
  }
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

data "digitalocean_database_cluster" "primary" {
  name        = module.db-cluster.cluster_name
  depends_on  = [module.db-cluster]
}

module "db-cluster" {
  source                = "./db-cluster"
  depends_on            = [module.doks-cluster]
  cluster_name          = local.db_cluster_name
  cluster_region        = var.do_region
  db_engine             = local.database.engine
  engine_version        = local.database.version
  cluster_upgrade_day   = var.db_cluster_auto_upgrade_day
  cluster_upgrade_time  = var.db_cluster_auto_upgrade_time
  node_size             = var.db_node_size
  node_count            = var.db_node_count
  k8s_cluster_name      = module.doks-cluster.cluster_name
  k8s_cluster_id        = module.doks-cluster.cluster_id
}

module "kubernetes-config" {
  source                = "./k8s-config"
  k8s_cluster_name      = module.doks-cluster.cluster_name
  k8s_cluster_id        = module.doks-cluster.cluster_id
  github_owner          = var.github_owner
  flux_repo_name        = var.flux_repo_name
  flux_repo_branch      = var.flux_repo_branch
  flux_target_path      = var.flux_target_path
}
