output "doks_cluster_name" {
  # Use with doctl to fetch the kubeconfig, e.g.:
  # doctl kubernetes cluster kubeconfig save $(terraform output -raw doks_cluster_name)
  value = module.doks-cluster.cluster_name
  description = "DOKS cluster name. Get the kubeconfig with: 'doctl kubernetes cluster kubeconfig save <value>'."
}

output "doks_cluster_endpoint" {
  value = module.doks-cluster.cluster_endpoint
  description = "Public hostname to reach the Kubernetes API endpoint for the DOKS cluster."
}

output "db_host_public" {
  value = module.db-cluster.db_host_public
  description = "Public hostname to reach the managed database cluster."
}

output "db_host_internal" {
  value = module.db-cluster.db_host_internal
  description = "Private hostname to reach the managed database cluster from the same VPC (region/datacentre)."
}

output "db_port" {
  value = module.db-cluster.db_port
  description = "TCP port to access the managed database cluster."
}

output "db_ca_cert" {
  value = module.db-cluster.db_ca_cert
  description = "CA SSL/TLS certificate for the managed database cluster."
}

output "db_default_user" {
  value = module.db-cluster.db_default_user
  description = "Default (primary) user for the managed database cluster."
}

output "db_default_password" {
  value = module.db-cluster.db_default_password
  description = "Password for the default (primary) user on the managed database cluster."
  sensitive = true
}
