variable "project_name" {
  type = string
  description = "Name your project, please."
}

variable "app_name" {
  type = string
  description = "Name your application, please."
}

variable "aws_account_id" {
  type = string
  description = "AWS Account ID."
}

variable "default_aws_region" {
  type = string
  description = "Default AWS region."
}

variable "ecr_url" {
  type = string
  description = "AWS ECR url."
}

variable "domain" {
  type = string
  description = "AWS Route 53 domain that you have previously bought manually."
}

variable "github_token" {
  type = string
  description = "GitHub token that will be used."
}