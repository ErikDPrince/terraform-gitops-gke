output "ingress_global_ip" {
  description = "Global static IP used by Ingress NGINX"
  value       = google_compute_address.ingress_ip.address
}
