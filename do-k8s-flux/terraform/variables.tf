variable "do_token" {
  description = "DigitalOcean API personal access token"
  type = string
  sensitive = true
}

variable "do_project_name" {
  description = "DigitalOcean project name"
  type = string
  default = "ebi-gallery"
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
