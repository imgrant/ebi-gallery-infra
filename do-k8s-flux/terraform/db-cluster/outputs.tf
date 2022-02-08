output "cluster_id" {
  value = digitalocean_database_cluster.primary.id
}

output "cluster_name" {
  value = digitalocean_database_cluster.primary.name
}

output "db_host_public" {
  value = digitalocean_database_cluster.primary.host
}

output "db_host_internal" {
  value = digitalocean_database_cluster.primary.private_host
}

output "db_port" {
  value = digitalocean_database_cluster.primary.port
}

output "db_default_user" {
  value = digitalocean_database_cluster.primary.user
}

output "db_default_password" {
  value = digitalocean_database_cluster.primary.password
  sensitive = true
}

output "db_ca_cert" {
  value = data.digitalocean_database_ca.primary.certificate
}
