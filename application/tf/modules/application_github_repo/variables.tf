variable "github_token" {
  description = "Github OAuth token that will be used to authenticate to your Github account and create the necessary repo."
  type        = string
}

variable "docker_hub_username" {
  description = "Docker Hub username"
  type        = string
}

variable "docker_hub_password" {
  description = "Docker Hub password"
  type        = string
}

variable "remote_host" {
  description = "Public IP of the jump server from the infrastructure module."
  type        = string
}

variable "ssh_private_key" {
  description = "Private SSH key used for promoting app version."
  type        = string
}

variable "wait_signal" {
  description = "Doesn't actually do anything. Used only for creating Terraform dependency."
  type        = string
}

#variable "ssh_key_public_path" {
#  description = "Public SSH key that will be used for deployment on the Application repository"
#}
#
#locals {
#  ssh_key_public = file(var.ssh_key_public_path)
#}