variable "access_key" {
  description = "AWS Access Key, what is there to say"
  type        = string
}

variable "secret_key" {
  description = "AWS Secret Key, what is there to say"
  type        = string
}

variable "default_region" {
  default     = "us-east-1"
  type        = string
  description = "Region for AWS. Default is us-east-1."
}

variable "project_name" {
  type        = string
  description = "Name your project, please."
}

variable "app_name" {
  type = string
  description = "Application name."
}

variable "email" {
  description = "Email that will be used for cert-manager."
  type        = string
}

variable "github_token" {
  type = string
  description = "GitHub token that will be used to create the repo and upload files."
}

variable "domain" {
  type = string
  description = "AWS Route53 domain that you purchased manually."
}