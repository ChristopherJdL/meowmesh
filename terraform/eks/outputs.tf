output "cluster_name" {
  value = aws_eks_cluster.meowmesh.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.meowmesh.endpoint
}

output "cluster_ca_data" {
  value = aws_eks_cluster.meowmesh.certificate_authority[0].data
}
