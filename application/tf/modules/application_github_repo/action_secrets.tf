resource "github_actions_secret" "github_repo_name" {
  repository      = github_repository.app_repo.name
  secret_name     = "REPO_NAME_GITHUB"
  plaintext_value = github_repository.app_repo.name
}

resource "github_actions_secret" "github_token" {
  repository      = github_repository.app_repo.name
  secret_name     = "DEPLOYMENT_TOKEN"
  plaintext_value = var.github_token
}

resource "github_actions_secret" "aws_account_id" {
  repository      = github_repository.app_repo.name
  secret_name     = "AWS_ACCOUNT_ID"
  plaintext_value = var.aws_account_id
}

resource "github_actions_secret" "aws_default_region" {
  repository      = github_repository.app_repo.name
  secret_name     = "DEFAULT_AWS_REGION"
  plaintext_value = var.default_aws_region
}

resource "github_actions_secret" "ecr_user_access_key" {
  repository      = github_repository.app_repo.name
  secret_name     = "ECR_USER_ACCESS_KEY"
  plaintext_value = var.ecr_user_access_key
}

resource "github_actions_secret" "ecr_user_secret_key" {
  repository      = github_repository.app_repo.name
  secret_name     = "ECR_USER_SECRET_KEY"
  plaintext_value = var.ecr_user_secret_key
}

resource "github_actions_secret" "ecr_name" {
  repository      = github_repository.app_repo.name
  secret_name     = "ECR_NAME"
  plaintext_value = var.ecr_name
}

resource "github_actions_secret" "github_repository_name" {
  repository      = github_repository.app_repo.name
  secret_name     = "REPOSITORY_NAME_GITHUB"
  plaintext_value = github_repository.app_repo.name
}

resource "github_actions_secret" "login_github" {
  repository      = github_repository.app_repo.name
  secret_name     = "LOGIN_GITHUB"
  plaintext_value = data.github_user.current.login
}

resource "github_actions_secret" "application_name" {
  repository      = github_repository.app_repo.name
  secret_name     = "APPLICATION_NAME"
  plaintext_value = var.application_name
}

