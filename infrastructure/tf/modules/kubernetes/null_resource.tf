resource "null_resource" "install_dependencies" {
  depends_on = [aws_instance.jump_server, null_resource.copy_files]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/.ssh/id_ed25519")
    host        = aws_instance.jump_server.public_ip
    timeout     = "5m"
  }

  provisioner "remote-exec" {
    inline = [
      "cd ~",
      "mkdir k8s_resources",
      "mv ./cert_manager.yaml k8s_resources",
      "curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl",
      "chmod +x ./kubectl",
      "mkdir ~/bin",
      "mv ./kubectl ~/bin/kubectl",
      "curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip",
      "unzip awscliv2.zip",
      "sudo ./aws/install",
      "export AWS_ACCESS_KEY_ID=${var.access_key}",
      "export AWS_SECRET_ACCESS_KEY=${var.secret_key}",
      "export AWS_DEFAULT_REGION=${var.default_region}",
      "aws configure set default.region $AWS_DEFAULT_REGION",
      "aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID",
      "aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY",
      "aws eks update-kubeconfig --name ${var.project_name} --region ${var.default_region}",
      "sudo wget -qO ~/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64",
      "sudo chmod a+x ~/bin/yq",
      "sudo yum update",
      "sudo yum install jq -y",
      "sudo yum install git -y",
      "curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 > get_helm.sh",
      "chmod 700 get_helm.sh",
      "./get_helm.sh",
      "helm repo add jetstack https://charts.jetstack.io",
      "kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.1.1/deploy/static/provider/cloud/deploy.yaml",
      "helm repo add nginx-stable https://helm.nginx.com/stable",
      "helm repo update",
      "helm install nginx-ingress nginx-stable/nginx-ingress --set controller.service.annotations.\"service\\.beta\\.kubernetes\\.io/aws-load-balancer-type\"=\"nlb\"",
      "helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --set installCRDs=true",
      "export PATH=$PATH:/home/ec2-user/bin:/home/ec2-user/.local/bin",
      "pwd && echo $PATH",
      "ls",
#      "kubectl apply -f /home/ec2-user/k8s_resources/cert_manager.yaml",
#      "mkdir infra_repo && cd infra_repo",
#      "git clone https://${var.github_token}@github.com/${data.github_user.current.login}/${var.project_name}-infra.git .",
    ]
  }
}

resource "null_resource" "copy_files" {
  depends_on = [aws_instance.jump_server, local_file.cert_manager, local_file.dns_record, local_file.values]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/.ssh/id_ed25519")
    host        = aws_instance.jump_server.public_ip
    timeout     = "5m"
  }

  provisioner "file" {
    source      = "infrastructure/tf/modules/kubernetes/k8s_resources/cert_manager.yaml"
    destination = "/home/ec2-user/cert_manager.yaml"
  }

  provisioner "file" {
    source      = "infrastructure/tf/modules/kubernetes/k8s_resources/values.yaml"
    destination = "/home/ec2-user/values.yaml"
  }
  provisioner "file" {
    source      = "infrastructure/tf/modules/kubernetes/k8s_resources/dns_record.json"
    destination = "/home/ec2-user/dns_record.json"
  }

}


resource "null_resource" "update_route53_record" {
  depends_on = [null_resource.install_dependencies]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/.ssh/id_ed25519")
    host        = aws_instance.jump_server.public_ip
    timeout     = "5m"
  }

  provisioner "remote-exec" {
    inline = [
      "cd ~",
      "export PATH=$PATH:/home/ec2-user/bin:/home/ec2-user/.local/bin",
      "while [ -z \"$BALANCER\" ]; do BALANCER=$(kubectl get svc | grep LoadBalancer | awk '{print $4}'); sleep 5; done",
      "cat dns_record.json | jq \".Changes[].ResourceRecordSet.ResourceRecords[].Value=\\\"$BALANCER\\\"\" > updated.json && mv updated.json dns_record.json",
      "aws route53 change-resource-record-sets --hosted-zone-id ${data.aws_route53_zone.domain.id} --change-batch \"$(cat ./dns_record.json)\""
    ]
  }
}

resource "null_resource" "initialize_infra_repo" {
  depends_on = [null_resource.update_route53_record, null_resource.install_dependencies, null_resource.copy_files]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/.ssh/id_ed25519")
    host        = aws_instance.jump_server.public_ip
    timeout     = "5m"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir infra_repo && cd infra_repo",
      "git clone https://${var.github_token}@github.com/${data.github_user.current.login}/${var.project_name}-infra.git .",
      "mkdir charts && cd charts",
      "helm create ${var.app_name}",
      "cd ../",
      "mv ~/values.yaml ~/infra_repo/charts/${var.app_name}/",
      "pwd && ls",
      "git status",
      "git add .",
      "git commit -m 'Add application chart'",
      "git push"
    ]
  }

}