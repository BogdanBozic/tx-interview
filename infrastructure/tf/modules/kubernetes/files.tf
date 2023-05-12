resource "local_file" "dns_record" {
  filename = "${path.module}/k8s_resources/dns_record.json"
  content = local.dns_record
}

resource "local_file" "cert_manager" {
  filename = "${path.module}/k8s_resources/cert_manager.yaml"
  content = local.cert_manager
}

resource "local_file" "ingress" {
  filename = "${path.module}/k8s_resources/ingress.yaml"
  content = local.ingress
}