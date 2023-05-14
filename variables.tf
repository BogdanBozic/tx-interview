variable "project_name" {
  type        = string
  description = "Name the project, please."
}

variable "app_name" {
  type        = string
  description = "Name your application, please."
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

variable "default_aws_region" {
  type        = string
  description = "Default AWS region."
}

variable "email" {
  type        = string
  description = "Personal email for use with Route 53 and cert-manager."
}

variable "domain" {
  type        = string
  description = "AWS Route 53 domain that you have previously bought manually. Example: example.com"
}