variable "deploy_argocd" {
  type    = bool
  default = true
}

variable "gke_endpoint" {
  type = string
}

variable "argocd_auth_token" {
  description = "Authentication token for ArgoCD"
  type        = string
  sensitive   = true
  default = ""
}
