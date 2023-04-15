resource "aws_eks_node_group" "goldbach" {
  cluster_name    = aws_eks_cluster.goldbach.name
  node_group_name = "goldbach"
  node_role_arn   = aws_iam_role.goldbach-worker.arn
  subnet_ids      = aws_subnet.goldbach_workers[*].id

  scaling_config {
    desired_size = 1
    max_size     = 3
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.goldbach-worker-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.goldbach-worker-AmazonEKS_CNI_Policy,
  ]
}