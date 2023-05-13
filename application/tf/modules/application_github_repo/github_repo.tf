resource "github_repository" "app_repo" {
  name        = "bogdan_goldbach_app_repo"
  description = "The application repository of the GolBach Interview Assignment. This sentence is only waiting for ${var.wait_signal}, don't mind it."
  visibility  = "public"
}
