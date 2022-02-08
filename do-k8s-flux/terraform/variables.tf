variable "do_token" {
  description = "DigitalOcean API personal access token"
  type = string
  sensitive = true
}

variable "do_spaces_access_key" {
  description = "DigitalOcean Spaces access key ID"
  type = string
}

variable "do_spaces_secret_key" {
  description = "DigitalOcean Spaces access key secret"
  type = string
  sensitive = true
}

variable "do_project_name" {
  description = "DigitalOcean project name"
  type = string
  default = "ebi-gallery"
}

variable "do_region" {
  description = "DigitalOcean datacentre region to deploy in"
  type = string
  default = "lon1"
}

variable "doks_cluster_version" {
  description = "Kubernetes version to use for DOKS cluster"
  default = "1.21"
}

variable "doks_cluster_auto_upgrade_day" {
  description = "Day of the week to perform cluster maintenance"
  type = string
  default = "sunday"
}

variable "doks_cluster_auto_upgrade_time" {
  description = "Start time (in UTC) for the maintenance window"
  type = string
  default = "04:00"
}

variable "doks_nodes_min" {
  description = "Minimum number of autoscaling nodes to deploy for DOKS cluster"
  type = number
  default = 1
}

variable "doks_nodes_max" {
  description = "Maximum number of autoscaling nodes to deploy for DOKS cluster"
  type = number
  default = 3
}

variable "doks_node_size" {
  description = "Size of droplets in the DOKS cluster node pool (use DO slug names)"
  type = string
  default = "s-1vcpu-2gb"
}

variable "db_cluster_auto_upgrade_day" {
  description = "Day of the week to perform cluster maintenance"
  type = string
  default = "sunday"
}

variable "db_cluster_auto_upgrade_time" {
  description = "Start time (in UTC) for the maintenance window"
  type = string
  default = "02:00:00"
}

variable "db_node_size" {
  description = "Size of droplets in the database cluster (use DO DB slug names)"
  type = string
  default = "db-s-1vcpu-1gb"
}

variable "db_node_count" {
  description = "Number of nodes to provision for the database cluster"
  type = number
  default = 1
}

variable "github_owner" {
  description = "User or organization owning the GitHub repository for Flux"
  type = string
}

variable "github_token" {
  description = "GitHub personal access token"
  type = string
  sensitive = true
}

variable "flux_repo_name" {
  description = "GitHub repository name for Flux (should already exist)"
  type = string
  default = "ebi-gallery-infra"
}

variable "flux_repo_branch" {
  description = "Branch to use on the GitHub repository for Flux"
  type = string
  default = "main"
}

variable "flux_target_path" {
  description = "Target path in the GitHub repo to use for Flux"
  type = string
  default = "do-k8s-flux/flux"
}