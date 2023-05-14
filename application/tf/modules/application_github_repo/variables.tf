variable "github_token" {
  description = "Github OAuth token that will be used to authenticate to your Github account and create the necessary repo."
  type        = string
}

variable "project_name" {
  type        = string
  description = "Name your project, please."
}

variable "app_name" {
  type = string
  description = "Name your application, please."
}

variable "ecr_url" {
  type        = string
  description = "ECR name where the app image will be stored."
}

variable "aws_account_id" {
  type        = number
  description = "AWS Account ID."
}

variable "default_aws_region" {
  type        = string
  description = "Default AWS region."
}

variable "ecr_user_access_key" {
  type        = string
  description = "AWS ECR user access key. Used for uploading container images."
}

variable "ecr_user_secret_key" {
  type        = string
  description = "AWS ECR user secret key. Used for uploading container images."
}

#variable "docker_hub_username" {
#  description = "Docker Hub username"
#  type        = string
#}
#
#variable "docker_hub_password" {
#  description = "Docker Hub password"
#  type        = string
#}

#variable "remote_host" {
#  description = "Public IP of the jump server from the infrastructure module."
#  type        = string
#}
#
#variable "ssh_private_key" {
#  description = "Private SSH key used for promoting app version."
#  type        = string
#}

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