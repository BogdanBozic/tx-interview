output "github_repo" {
  value = github_repository.app_repo.ssh_clone_url
}

output "aws_secret" {
  value = var.ecr_user_secret_key
}

output "aws_access" {
  value = var.ecr_user_access_key
}