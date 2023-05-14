module "application" {
  source = "./application/tf/modules/application_github_repo"

  project_name        = var.project_name
  app_name = var.app_name
  github_token        = var.github_token
  ecr_url             = module.infrastructure.ecr_url
  ecr_user_access_key = module.infrastructure.ecr_user_access_key
  ecr_user_secret_key = module.infrastructure.ecr_user_secret_key
  aws_account_id      = module.infrastructure.aws_account_id
  default_aws_region  = var.default_aws_region

  wait_signal = module.infrastructure.wait_signal
}

module "infrastructure" {
  source = "./infrastructure/tf/modules/kubernetes"

  access_key     = var.access_key
  secret_key     = var.secret_key
  default_region = var.default_aws_region
  domain         = var.domain

  email        = var.email
  github_token = var.github_token

  project_name = var.project_name
  app_name     = var.app_name
}

module "infra_repo" {
  source = "./infra_repo/tf/modules/infra_github_repo"

  app_name           = var.app_name
  project_name       = var.project_name
  aws_account_id     = module.infrastructure.aws_account_id
  default_aws_region = var.default_aws_region
  ecr_url            = module.infrastructure.ecr_url
  domain             = var.domain
  github_token       = var.github_token
}