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
