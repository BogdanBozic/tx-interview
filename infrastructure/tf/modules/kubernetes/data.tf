data "aws_ami" "eks-worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${aws_eks_cluster.goldbach.version}-v*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon EKS AMI Account ID
}

data "aws_availability_zones" "azs" {
  state = "available"
}

data "aws_region" "current" {}

data "http" "self-ip" {
  url = "http://ipv4.icanhazip.com"
}

data "aws_caller_identity" "current" {}


#data "aws_ami" "eks_worker" {
#  filter {
#    name   = "name"
#    values = ["amazon-eks-node-*-latest-*"]
#  }
#
#  filter {
#    name   = "virtualization-type"
#    values = ["hvm"]
#  }
#
#  owners = ["amazon"]
#}