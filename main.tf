module "application" {
  source = "./application/tf/modules/application_github_repo"

  docker_hub_password = var.docker_hub_password
  docker_hub_username = var.docker_hub_username
  github_token        = var.github_token
  remote_host         = module.infrastructure.jump_server_ip
  ssh_private_key     = file("~/.ssh/id_ed25519")

  wait_signal = module.infrastructure.wait_signal
}

module "infrastructure" {
  source = "./infrastructure/tf/modules/kubernetes"

  access_key = var.access_key
  secret_key = var.secret_key
  email = var.email
}