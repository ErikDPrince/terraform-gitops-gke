terraform-gitops-gke
Overview
This repository provides a complete Infrastructure-as-Code (IaC) solution for deploying and managing a Google Kubernetes Engine (GKE) cluster using Terraform. It enables GitOps continuous delivery with ArgoCD and automated image updates via ArgoCD Image Updater.


Features
GKE Cluster Provisioning: Automated creation and management of a GKE cluster and node pools.
ArgoCD Deployment: Installs ArgoCD for GitOps-based application delivery.
ArgoCD Image Updater: Automatically updates Kubernetes workloads when new container images are available.
Ingress, Cert-Manager, External-DNS: Installs and configures ingress, TLS certificates, and DNS automation.
Modular Design: Infrastructure is organized into reusable Terraform modules.
Secure & Flexible: Supports secret management, RBAC, and integration with multiple container registries.

Project Structure
```
terraform-gitops-gke/
├── main.tf                # Main Terraform configuration, wires modules together
├── variables.tf           # Input variables for the deployment
├── outputs.tf             # Output values
├── providers.tf           # Provider configuration (Google, Helm, Kubernetes)
├── terraform.tfvars       # Environment-specific variable values
├── modules/
│   ├── gke/               # GKE cluster and node pool
│   ├── argocd/            # ArgoCD and Image Updater deployment
│   ├── ingress/           # Ingress, cert-manager, external-dns
│   └── apps/              # (Optional) Application deployment logic
└── README.md              # This file
```

Getting Started
1. Configure Variables
Edit `terraform.tfvars` with your GCP project, region, and other settings.

2. Initialize Terraform
```sh
terraform init
```

3. Apply Infrastructure
```sh
terraform apply
```
Or, to skip the approval prompt:
```sh
terraform apply -auto-approve
```

4. Set Up ArgoCD Image Updater
- Generate an ArgoCD API token and update `terraform.tfvars` with it.
- Re-apply Terraform to deploy the Image Updater.

5. Add Image Updater Annotations
In your GitOps repo, add image updater annotations to your ArgoCD Application YAMLs to enable automated image updates.

Example: Application Annotation
```yaml
metadata:
  annotations:
    argocd-image-updater.argoproj.io/image-list: myapp=your-repo/your-image
    argocd-image-updater.argoproj.io/myapp.update-strategy: latest
```

Troubleshooting
- **Pod Pending:** Check node resources and increase node count if needed.
- **Image Updater Not Working:** Check logs with  
  ```sh
  kubectl logs -n argocd deployment/argocd-image-updater
  ```
- **ArgoCD UI:**  
  ```sh
  kubectl port-forward svc/argocd-server -n argocd 8080:443
  # Visit http://localhost:8080
  ```

References
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [ArgoCD Image Updater Docs](https://argocd-image-updater.readthedocs.io/)
- [Terraform GKE Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster)

Feel free to further customize this README for your team or project needs! If you want to add more sections (like CI/CD, security, or contribution guidelines), just let me know.