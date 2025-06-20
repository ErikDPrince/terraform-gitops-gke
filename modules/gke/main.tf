resource "google_container_cluster" "primary" {
  name     = "gke-cluster"
  location = var.region

  remove_default_node_pool = true
  initial_node_count       = 1 # ✅ allowed ONLY if no node_pool defined
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "primary-node-pool"
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = 1

  # Explicitly tell GKE to only create the node in a single zone
  
  node_locations = [
    "${var.region}-a",
  ]
  
  node_config {
    machine_type = "e2-medium"
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
}



output "endpoint" {
  value = google_container_cluster.primary.endpoint
}

output "name" {
  value = google_container_cluster.primary.name
}

output "cluster_ca_certificate" {
  value = google_container_cluster.primary.master_auth[0].cluster_ca_certificate
}
