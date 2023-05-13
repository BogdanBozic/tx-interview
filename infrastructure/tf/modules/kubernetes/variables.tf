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

variable "application_name" {
  type        = string
  description = "Name your application, please."
}

variable "cluster_name" {
  default     = "goldbach"
  type        = string
  description = "Name of the AWS EKS cluster to create. Default is goldbach."
}

variable "email" {
  description = "Email that will be used for cert-manager."
  type        = string
}