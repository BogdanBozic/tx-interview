#locals {
#  chart_dir = "${path.module}/infra_repo/charts/${var.app_name}"
#}
#
#resource "local_file" "values" {
#  filename = "${local.chart_dir}/actual-values.yaml"
#  content  = local.values
#}

#resource "github_repository_file" "chart" {
#  content             = file("${local.chart_dir}/actual-values.yaml")
#  file                = "charts/${var.app_name}/actual-values.yaml"
#  repository          = github_repository.infra_repo.name
#  overwrite_on_create = true
#  commit_message      = "Upload actual-values.yaml"
#}
#
resource "github_repository_file" "readme" {
  content             = "Readme file."
  file                = "README.md"
  repository          = github_repository.infra_repo.name
  overwrite_on_create = true
  commit_message      = "Upload readme"
}