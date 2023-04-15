resource "aws_eks_cluster" "goldbach" {
  name     = var.cluster_name
  role_arn = aws_iam_role.goldbach_master.arn

  vpc_config {
    security_group_ids = [aws_security_group.goldbach_master.id]
    subnet_ids         = aws_subnet.goldbach_control_plane.*.id
  }

  depends_on = [
    aws_iam_role_policy_attachment.goldbach-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.goldbach-AmazonEKSServicePolicy,
  ]
}
