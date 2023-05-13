### Master Node ###

resource "aws_iam_role" "goldbach_master" {
  name = "goldbach"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "goldbach-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.goldbach_master.name
}

resource "aws_iam_role_policy_attachment" "goldbach-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.goldbach_master.name
}

### End Master Node ###

### Worker Nodes ###

resource "aws_iam_role" "goldbach-worker" {
  name = "goldbach-worker"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "goldbach-worker-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.goldbach-worker.name
}

resource "aws_iam_role_policy_attachment" "goldbach-worker-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.goldbach-worker.name
}

resource "aws_iam_role_policy_attachment" "example-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.goldbach-worker.name
}

### End Worker Nodes ###

### Cert Manager ###

resource "aws_iam_policy" "policy_for_cert_manager" {
  name = "PolicyForCertManager"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "route53:GetChange",
        "Resource" : "arn:aws:route53:::change/*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "route53:ChangeResourceRecordSets",
          "route53:ListResourceRecordSets"
        ],
        "Resource" : "arn:aws:route53:::hostedzone/${data.aws_route53_zone.bastovansurcinski.id}"
      },
      {
        "Action" : "sts:AssumeRole",
        "Effect" : "Allow",
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role" "cert_manager_role" {
  name = "RoleForCertManager"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.goldbach-worker.name}"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cert_manager" {
  policy_arn = aws_iam_policy.policy_for_cert_manager.arn
  role       = aws_iam_role.cert_manager_role.name
}

resource "aws_iam_role_policy_attachment" "worker_cert_manager" {
  policy_arn = aws_iam_policy.policy_for_cert_manager.arn
  role       = aws_iam_role.goldbach-worker.name
}

### END Cert Manager ###

### ECR ###

resource "aws_iam_user" "github_image_upload" {
  name = "${var.application_name}_github_image_upload"
}

resource "aws_iam_access_key" "ecr_user_access_key" {
  user = aws_iam_user.github_image_upload.name
}

data "aws_iam_policy_document" "ecr_user_policy_document" {
  statement {
    sid       = "AllowECRAccess"
    effect    = "Allow"
    actions   = ["ecr:*"]
    resources = ["arn:aws:ecr:${var.default_region}:${data.aws_caller_identity.current.account_id}:repository/${aws_ecr_repository.application_repo.name}"]
  }

  statement {
    sid = "AllowGetToken"
    effect = "Allow"
    actions = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }
}

resource "aws_iam_user_policy" "ecr_user_policy" {
  policy = data.aws_iam_policy_document.ecr_user_policy_document.json
  user   = aws_iam_user.github_image_upload.name
}

### END ECR ###