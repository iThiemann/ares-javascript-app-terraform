
output "kubeconfig" {
  description = "Kubeconfig for the kind cluster"
  value       = kind_cluster.dev.kubeconfig
  sensitive   = true
}
