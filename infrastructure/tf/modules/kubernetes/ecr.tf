resource "aws_ecr_repository" "application_repo" {
  name = var.application_name
}
