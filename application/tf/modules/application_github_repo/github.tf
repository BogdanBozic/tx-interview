resource "github_repository" "app_repo" {
  name        = "bogdan_goldbach_app_repo"
  description = "The application repository of the GolBach Interview Assignment"
  visibility = "public"
}

### Workflows Setup ###
resource "github_repository_environment" "repo_environment" {
  repository       = github_repository.app_repo.name
  environment      = "default"
}

resource "github_actions_environment_secret" "github_token" {
  repository       = github_repository.app_repo.name
  environment      = github_repository_environment.repo_environment.environment
  secret_name      = "DEPLOYMENT_TOKEN"
  plaintext_value  = var.github_token
}

### End Workflows Setup ###

#resource "github_repository_deploy_key" "deploy_ssh_key" {
#  title      = "Repository SSH deploy key"
#  repository = github_repository.app_repo.name
#  key        = local.ssh_key_public
#  read_only  = "false"
#}

### Github Files ###
resource "github_repository_file" "readme" {
  repository     = github_repository.app_repo.name
  file           = "README.md"
  content        = file("${path.module}/../../../../application/README.md")
  commit_message = "Upload README file"
  overwrite_on_create = true
}

resource "github_repository_file" "main-py" {
  repository     = github_repository.app_repo.name
  file           = "app/main.py"
  content        = file("${path.module}/../../../../application/app/main.py")
  commit_message = "Upload main.py file"
  overwrite_on_create = true
}

resource "github_repository_file" "requirements-txt" {
  repository     = github_repository.app_repo.name
  file           = "app/requirements.txt"
  content        = file("${path.module}/../../../../application/app/requirements.txt")
  commit_message = "Upload Python requirements file"
  overwrite_on_create = true
}

resource "github_repository_file" "unit_test" {
  repository     = github_repository.app_repo.name
  file           = "app/test_main.py"
  content        = file("${path.module}/../../../../application/app/test_main.py")
  commit_message = "Upload unit tests"
  overwrite_on_create = true
}

resource "github_repository_file" "github-actions" {
  content    = file("${path.module}/../../../../application/app/.github/workflows/deploy.yml")
  file       = ".github/workflows/deploy.yml"
  repository = github_repository.app_repo.name
  overwrite_on_create = true
  commit_message = "Upload Github Actions"
}

resource "github_repository_file" "dockerfile" {
  content    = file("${path.module}/../../../../application/Dockerfile")
  file       = "Dockerfile"
  repository = github_repository.app_repo.name
  overwrite_on_create = true
  commit_message = "Upload Dockerfile"
}

### End Github Files ###