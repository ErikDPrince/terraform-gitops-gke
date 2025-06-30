resource "helm_release" "argocd" {
  count              = var.deploy_argocd ? 1 : 0
  name               = "argocd"
  namespace          = "argocd"
  create_namespace   = true
  repository         = "https://argoproj.github.io/argo-helm"
  chart              = "argo-cd"
  version            = "5.51.6"
  values             = [file("${path.module}/values.yaml")]

}

resource "null_resource" "verify_argocd" {
   count = var.deploy_argocd ? 1 : 0

  provisioner "local-exec" {
    command = <<EOT
      echo "[INFO] Waiting for ArgoCD server to be available..."
      kubectl wait --for=condition=Available deployment/argocd-server -n argocd --timeout=180s

      if [ $? -eq 0 ]; then
        echo "[✔] ArgoCD installed successfully at $(date)" | tee -a argocd-install.log
      else
        echo "[✘] ArgoCD installation failed or timed out at $(date)" | tee -a argocd-install.log
        exit 1
      fi
    EOT
    interpreter = ["/bin/bash", "-c"]
  }

  depends_on = [helm_release.argocd]
}

resource "helm_release" "argocd_image_updater" {
  count = var.deploy_argocd ? 1 : 0

  name       = "argocd-image-updater"
  namespace  = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-image-updater"
  version    = "0.12.0"

  values = [yamlencode({
    config = {
      logLevel = "info"
      registries = [
        {
          name = "dockerhub"
          api_url = "https://registry-1.docker.io"
          prefix = "docker.io"
          credentials = "secret:argocd/argocd-image-updater#dockerhub"
        },
        {
          name = "ghcr"
          api_url = "https://ghcr.io"
          prefix = "ghcr.io"
          credentials = "secret:argocd/argocd-image-updater#ghcr"
        }
      ]
    }
    argoCD = {
      config = {
        apiServer = "http://argocd-server.argocd.svc"
        plaintext = true
        insecure  = true
      }
    }
    serviceAccount = {
      create = true
      name   = "argocd-image-updater"
    }
    rbac = {
      create = true
      pspEnabled = false
    }
    image = {
      tag = "v0.12.0"
    }
    resources = {
      limits = {
        cpu    = "200m"
        memory = "256Mi"
      }
      requests = {
        cpu    = "100m"
        memory = "128Mi"
      }
    }
  })]

  set_sensitive = [
    {
      name  = "env[0].value"
      value = var.argocd_auth_token
    }
  ]

  set = [
    {
      name  = "env[0].name"
      value = "ARGOCD_AUTH_TOKEN"
    }
  ]

  depends_on = [helm_release.argocd]
}
