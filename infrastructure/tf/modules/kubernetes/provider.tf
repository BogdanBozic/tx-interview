provider "aws" {
  region     = var.default_region
  access_key = var.access_key
  secret_key = var.secret_key
}

provider "github" {
  token = var.github_token
}
