output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "jump_server_ip" {
  value = aws_instance.jump_server.public_ip
}

output "ecr_url" {
  value = aws_ecr_repository.application_repo.repository_url
}

output "ecr_user_access_key" {
  value = aws_iam_access_key.ecr_user_access_key.id
}

output "ecr_user_secret_key" {
  value = aws_iam_access_key.ecr_user_access_key.secret
}

output "wait_signal" {
  value = null_resource.update_route53_record.id
}