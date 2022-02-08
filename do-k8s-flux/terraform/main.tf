terraform {
  required_version = ">= 1.1.2"
}

provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_project" "active" {
  name = var.do_project_name
  description = "EBI01948 technical challenge"
  environment = "Staging"
  resources = []
}