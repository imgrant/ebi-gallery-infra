variable "cluster_name" {
  type = string
}

variable "cluster_region" {
  type = string
}

variable "cluster_upgrade_day" {
  type = string
}

variable "cluster_upgrade_time" {
  type = string
}

variable "db_engine" {
  type = string
}

variable "engine_version" {
  type = string
}

variable "node_size" {
  type = string
}

variable "node_count" {
  type = number
}

variable "k8s_cluster_name" {
  type = string
}

variable "k8s_cluster_id" {
  type = string
}
