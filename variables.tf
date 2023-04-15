variable "docker_hub_password" {
  type        = string
  description = "Docker Hub Password for application image upload."
}

variable "docker_hub_username" {
  type        = string
  description = "Docker Hub Username for application image upload."
}

variable "github_token" {
  type        = string
  description = "Github Token for creating a new application repo."
}

variable "access_key" {
  type        = string
  description = "AWS Access Key used for provisioning infrastructure."
}

variable "secret_key" {
  type        = string
  description = "AWS Secret Key used for provisioning infrastructure."
}

variable "email" {
  type        = string
  description = "Personal email for use with Route 53 and cert-manager."
}