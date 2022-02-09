terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = ">= 4.5.2"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = ">= 2.7.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.4.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.10.0"
    }
    flux = {
      source  = "fluxcd/flux"
      version = ">= 0.0.13"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "3.1.0"
    }
  }
}

locals {
  known_hosts = "github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg="
}

resource "tls_private_key" "flux_deploy_key" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

data "flux_install" "main" {
  target_path = var.flux_target_path
}

data "flux_sync" "main" {
  target_path = var.flux_target_path
  url         = "ssh://git@github.com/${var.github_owner}/${var.flux_repo_name}.git"
  branch      = var.flux_repo_branch
}

resource "kubernetes_namespace" "flux_system" {
  metadata {
    name = "flux-system"
  }

  lifecycle {
    ignore_changes = [
      metadata[0].labels,
    ]
  }
}

data "kubectl_file_documents" "install" {
  content = data.flux_install.main.content
}

data "kubectl_file_documents" "sync" {
  content = data.flux_sync.main.content
}

locals {
  install = [for v in data.kubectl_file_documents.install.documents : {
    data : yamldecode(v)
    content : v
    }
  ]
  sync = [for v in data.kubectl_file_documents.sync.documents : {
    data : yamldecode(v)
    content : v
    }
  ]
}

resource "kubectl_manifest" "install" {
  for_each   = { for v in local.install : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
  depends_on = [kubernetes_namespace.flux_system]
  yaml_body  = each.value
}

resource "kubectl_manifest" "sync" {
  for_each   = { for v in local.sync : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
  depends_on = [kubernetes_namespace.flux_system]
  yaml_body  = each.value
}

resource "kubernetes_secret" "flux_deploy_key" {
  depends_on = [kubectl_manifest.install]

  metadata {
    name      = data.flux_sync.main.secret
    namespace = data.flux_sync.main.namespace
  }

  data = {
    identity       = tls_private_key.flux_deploy_key.private_key_pem
    "identity.pub" = tls_private_key.flux_deploy_key.public_key_pem
    known_hosts    = local.known_hosts
  }
}

data "github_repository" "flux_infra_repo" {
  full_name = "${var.github_owner}/${var.flux_repo_name}"
}

resource "github_repository_deploy_key" "flux_deploy_key" {
  title      = var.k8s_cluster_name
  repository = data.github_repository.flux_infra_repo.name
  key        = tls_private_key.flux_deploy_key.public_key_openssh
  read_only  = true
}

resource "github_repository_file" "install" {
  repository = data.github_repository.flux_infra_repo.name
  file       = data.flux_install.main.path
  content    = data.flux_install.main.content
  branch     = var.flux_repo_branch
  overwrite_on_create = true
}

resource "github_repository_file" "sync" {
  repository = data.github_repository.flux_infra_repo.name
  file       = data.flux_sync.main.path
  content    = data.flux_sync.main.content
  branch     = var.flux_repo_branch
  overwrite_on_create = true
}

resource "github_repository_file" "kustomize" {
  repository = data.github_repository.flux_infra_repo.name
  file       = data.flux_sync.main.kustomize_path
  content    = data.flux_sync.main.kustomize_content
  branch     = var.flux_repo_branch
  overwrite_on_create = true
}
