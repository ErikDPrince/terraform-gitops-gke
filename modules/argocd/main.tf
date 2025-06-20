resource "helm_release" "argocd" {
  count              = var.deploy_argocd ? 1 : 0
  name               = "argocd"
  namespace          = "argocd"
  create_namespace   = true
  repository         = "https://argoproj.github.io/argo-helm"
  chart              = "argo-cd"
  version            = "5.51.6"
}

output "argocd_url" {
  value = var.deploy_argocd ? "https://${var.gke_endpoint}" : ""
}
