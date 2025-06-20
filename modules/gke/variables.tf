variable "cluster_name" {
  description = "Name of the GKE cluster"
  default = "gke-cluster"
  type        = string
}

variable "region" {
  description = "GCP region for the cluster"
  type        = string
}
