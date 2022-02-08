variable "do_token" {
  description = "DigitalOcean API personal access token"
  type = string
  sensitive = true
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
