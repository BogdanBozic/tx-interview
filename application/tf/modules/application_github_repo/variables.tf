variable "github_token" {
  description = "Github OAuth token that will be used to authenticate to your Github account and create the necessary repo."
  type = string
}

variable "destroy" {
  description = "Used at the time of destroying the infrastructure to cleanup"
  default = false
  type = bool
}

variable "docker_hub_username" {
  description = "Docker Hub username"
  type = string
}

variable "docker_hub_password" {
  description = "Docker Hub password"
  type = string
}

#variable "ssh_key_public_path" {
#  description = "Public SSH key that will be used for deployment on the Application repository"
#}
#
#locals {
#  ssh_key_public = file(var.ssh_key_public_path)
#}