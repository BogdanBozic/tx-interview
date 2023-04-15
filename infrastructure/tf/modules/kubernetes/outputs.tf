#output "kubeconfig" {
#  value = local.kubeconfig
#}
#
#output "config_map_aws_auth" {
#  value = local.config_map_aws_auth
#}

output "jump_server_ip" {
  value = aws_instance.jump_server.public_ip
}

output "wait_signal" {
  value = null_resource.update_route53_record.id
}