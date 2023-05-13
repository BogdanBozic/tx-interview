module "application" {
  source = "./application/tf/modules/application_github_repo"

  application_name    = var.application_name
  github_token        = var.github_token
  ecr_name            = module.infrastructure.ecr_name
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

  email = var.email

  application_name = var.application_name
}