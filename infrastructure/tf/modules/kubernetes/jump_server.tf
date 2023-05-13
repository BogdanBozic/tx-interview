# Define the key pair
resource "aws_key_pair" "my_keypair" {
  key_name   = "my_keypair"
  public_key = file("~/.ssh/id_ed25519.pub")
}

# Define the IAM instance profile
resource "aws_iam_instance_profile" "jump_server" {
  name = "jump_server"
  role = aws_iam_role.jump_server.name
}

# Define the EC2 instance
resource "aws_instance" "jump_server" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.jump_server.id
  vpc_security_group_ids      = [aws_security_group.jump_server.id]
  key_name                    = aws_key_pair.my_keypair.key_name
  iam_instance_profile        = aws_iam_instance_profile.jump_server.name
  associate_public_ip_address = true

  depends_on = [aws_eks_cluster.goldbach,
    aws_eks_node_group.goldbach,
    aws_vpc.goldbach,
    aws_security_group.goldbach_master,
    aws_route_table.goldbach,
    aws_vpc_security_group_ingress_rule.goldbach_master_kubectl,
    aws_nat_gateway.goldbach,
    aws_iam_role_policy_attachment.example-AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.worker_cert_manager,
    aws_iam_role_policy_attachment.cert_manager,
    aws_vpc_security_group_ingress_rule.jump_server_ssh,
    aws_iam_policy.cert_manager,
    aws_vpc_security_group_egress_rule.jump_server_outbound,
    aws_route_table_association.goldbach_worker,
    aws_route_table_association.jump_server,
    aws_vpc_security_group_egress_rule.eks_cluster_outbound,
    aws_vpc_security_group_egress_rule.goldbach_worker_outbound_all,
    aws_iam_role.cert_manager_role,
    aws_iam_policy.policy_for_cert_manager,
    aws_route_table.goldbach_worker
  ]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/.ssh/id_ed25519")
    host        = self.public_ip
    timeout     = "5m"
  }

  provisioner "remote-exec" {
    when = destroy
    inline = [
      "export PATH=$PATH:/home/ec2-user/bin:/home/ec2-user/.local/bin",
      "cd /home/ec2-user/k8s_resources",
      "kubectl delete -f .",
      "helm delete cert-manager",
      "helm delete nginx-ingress",
      "cd /home/ec2-user/",
      "cat dns_record.json | jq '.Changes[].Action = \"DELETE\"' > updated.json && mv updated.json dns_record.json",
      "aws route53 change-resource-record-sets --hosted-zone-id Z1031823IF2XGN2I3WHM --change-batch \"$(cat ./dns_record.json)\"",
    ]
  }

  tags = {
    Name = "jump-server"
  }
}

resource "aws_iam_role" "jump_server" {
  name = "ec2_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_security_group" "jump_server" {
  name        = "jump_server"
  description = "Security group for goldbach jump server"
  vpc_id      = aws_vpc.goldbach.id
}

resource "aws_vpc_security_group_ingress_rule" "jump_server_ssh" {
  security_group_id = aws_security_group.jump_server.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}

resource "aws_vpc_security_group_egress_rule" "jump_server_outbound" {
  security_group_id = aws_security_group.jump_server.id

  description = "Allow all outbound traffic."
  from_port   = "-1"
  to_port     = "-1"
  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}


resource "aws_subnet" "jump_server" {
  cidr_block        = "10.0.50.0/24"
  vpc_id            = aws_vpc.goldbach.id
  availability_zone = data.aws_availability_zones.azs.names[0]

  tags = {
    Name = "jump_server"
  }
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

resource "aws_route_table_association" "jump_server" {
  route_table_id = aws_route_table.goldbach.id
  subnet_id      = aws_subnet.jump_server.id
}