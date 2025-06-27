output "gke_endpoint" {
  value = module.gke.endpoint
}

output "argocd_url" {
  value = module.argocd.argocd_url
}

output "nginx_ingress_ip" {
  value       = module.ingress.ingress_global_ip
  description = "Static IP address reserved for Ingress NGINX controller"
}