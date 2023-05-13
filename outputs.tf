output "jump_server_ip" {
  value = module.infrastructure.jump_server_ip
}

output "aws_account" {
  value = module.infrastructure.ecr_user_access_key
}

output "aws_secret" {
  value = module.infrastructure.ecr_user_secret_key
  sensitive = true
}