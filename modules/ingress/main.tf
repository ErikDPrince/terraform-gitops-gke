resource "google_compute_address" "ingress_ip" {
  name = "ingress-nginx-ip"
  region = var.region
}

resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"

  values = [yamlencode({
    controller = {
      ingressClass = "nginx"
      ingressClassResource = {
        name = "nginx"
      }
      publishService = {
        enabled = true
      }
      service = {
        loadBalancerIP = google_compute_address.ingress_ip.address
        annotations = {
          "networking.gke.io/load-balancer-type" = "External"
        }
      }
    }
  })]
}


resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  namespace  = "cert-manager"
  create_namespace = true
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.14.3"

  set = [
    {
        name  = "installCRDs"
        value = "true"
    }
  ]
}

resource "helm_release" "external_dns" {
  name       = "external-dns"
  namespace  = "external-dns"
  create_namespace = true
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "external-dns"

  values = [yamlencode({
    provider = "google"
    google = {
      project = var.project_id
    }
    domainFilters = [var.domain]
    policy        = "sync"
    sources       = ["ingress"]
    txtOwnerId    = "externaldns-gke"
    serviceAccount = {
      create = true
      name   = "external-dns"
    }
  })]
}
