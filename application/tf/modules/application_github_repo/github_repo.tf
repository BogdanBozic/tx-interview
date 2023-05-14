resource "github_repository" "app_repo" {
  name        = "${var.project_name}-${var.app_name}"
  description = "The application repository of the ${var.project_name} project. This sentence is only waiting for ${var.wait_signal}, delete after initialization."
  visibility  = "public"
}
