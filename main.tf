module "gke" {
  source     = "./modules/gke"
  //project_id = var.project_id
  region     = var.region
  cluster_name = var.gke_cluster_name
}

module "argocd" {
  source        = "./modules/argocd"
  deploy_argocd = var.deploy_argocd
  gke_endpoint  = module.gke.endpoint
}

module "apps" {
  source       = "./modules/apps"
  deploy_apps  = var.deploy_apps
}


#### Helm install for Ingress NGINX, cert-manager, external-dns ###
module "ingress" {
  source           = "./modules/ingress"
  project_id       = var.project_id
  region           = var.region
  domain           = var.domain
}