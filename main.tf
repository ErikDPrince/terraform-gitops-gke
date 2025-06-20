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