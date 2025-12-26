output "eks_cluster_id" {
  value = aws_eks_cluster.this.id
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.this.endpoint
}

output "eks_cluster_certificate" {
  value = aws_eks_cluster.this.certificate_authority[0].data
}

output "node_group_name" {
  value = aws_eks_node_group.default.node_group_name
}
