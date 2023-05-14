resource "github_repository" "infra_repo" {
  name        = "${var.project_name}-infra"
  description = "Infrastructure for ${var.project_name} project."
  visibility  = "public"
}
