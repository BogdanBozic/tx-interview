resource "aws_ecr_repository" "application_repo" {
  name = var.project_name
  force_delete = true
}
