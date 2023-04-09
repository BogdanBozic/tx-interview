variable "github_token" {
  description = "Github OAuth token that will be used to authenticate to your Github account and create the necessary repo."
}

#variable "ssh_key_public_path" {
#  description = "Public SSH key that will be used for deployment on the Application repository"
#}
#
#locals {
#  ssh_key_public = file(var.ssh_key_public_path)
#}