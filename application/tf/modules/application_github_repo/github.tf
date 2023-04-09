resource "github_repository" "app_repo" {
  name        = "bogdan_goldbach_app_repo"
  description = "The application repository of the GolBach Interview Assignment"
}

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