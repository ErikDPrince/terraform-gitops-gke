output "gke_endpoint" {
  value = module.gke.endpoint
}

output "argocd_url" {
  value = module.argocd.argocd_url
}
