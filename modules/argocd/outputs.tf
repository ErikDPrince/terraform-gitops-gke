output "argocd_url" {
  description = "The ArgoCD URL if deployed"
  value       = var.deploy_argocd && length(helm_release.argocd) > 0 ? "https://${var.gke_endpoint}" : null
}
