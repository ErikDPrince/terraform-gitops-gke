variable "project_id" {
  default = "onyx-link-458909-g6"  
}
variable "region" {
  default = "asia-southeast1"
}
variable "gke_cluster_name" {
  default = "gitops-cluster"
}
variable "domain" {
  default = "minigameonline.net"
}

# set flag for deployment
variable "deploy_apps" {
  description = "Toggle to deploy apps"
  type        = bool
  default     = false
}

# set flag for deployment
variable "deploy_argocd" {
  description = "Toggle to deploy ArgoCD"
  type        = bool
  default     = false
}
