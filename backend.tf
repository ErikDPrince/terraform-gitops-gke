terraform {
  backend "gcs" {
    bucket  = "terraform-gitops-gke"
    prefix  = "envs/dev/terraform.tfstate"
  }
}
