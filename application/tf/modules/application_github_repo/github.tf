resource "github_repository" "app_repo" {
  name        = "bogdan_goldbach_app_repo"
  description = "The application repository of the GolBach Interview Assignment"
  visibility = "public"
}

### Workflows Setup ###

resource "github_actions_secret" "github_repo_name" {
  repository       = github_repository.app_repo.name
  secret_name      = "REPO_NAME_GITHUB"
  plaintext_value  = github_repository.app_repo.name
}

resource "github_actions_secret" "github_token" {
  repository       = github_repository.app_repo.name
  secret_name      = "DEPLOYMENT_TOKEN"
  plaintext_value  = var.github_token
}

resource "github_actions_secret" "docker_hub_username" {
  repository  = github_repository.app_repo.name
  secret_name = "DOCKER_HUB_USERNAME"
  plaintext_value  = var.docker_hub_username
}

resource "github_actions_secret" "docker_hub_password" {
  repository  = github_repository.app_repo.name
  secret_name = "DOCKER_HUB_PASSWORD"
  plaintext_value  = var.docker_hub_password
}

resource "github_actions_secret" "github_repository_name" {
  repository  = github_repository.app_repo.name
  secret_name = "REPOSITORY_NAME_GITHUB"
  plaintext_value  = github_repository.app_repo.name
}

### End Workflows Setup ###

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