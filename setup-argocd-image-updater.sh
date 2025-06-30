#!/bin/bash

set -e

echo "🚀 Setting up ArgoCD Image Updater..."

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed. Please install kubectl first."
    exit 1
fi

# Check if ArgoCD is running
echo "📋 Checking ArgoCD status..."
if ! kubectl get deployment argocd-server -n argocd &> /dev/null; then
    echo "❌ ArgoCD is not installed or not running. Please deploy ArgoCD first."
    exit 1
fi

# Wait for ArgoCD to be ready
echo "⏳ Waiting for ArgoCD to be ready..."
kubectl wait --for=condition=Available deployment/argocd-server -n argocd --timeout=300s

# Get ArgoCD admin password
echo "🔐 Getting ArgoCD admin password..."
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "ArgoCD admin password: $ARGOCD_PASSWORD"

# Port forward ArgoCD server
echo "🔌 Setting up port forward for ArgoCD server..."
kubectl port-forward svc/argocd-server -n argocd 8080:443 &
PF_PID=$!

# Wait for port forward to be ready
sleep 5

# Login to ArgoCD and get auth token
echo "🔑 Logging into ArgoCD and generating auth token..."
ARGOCD_AUTH_TOKEN=$(argocd login localhost:8080 --username admin --password "$ARGOCD_PASSWORD" --grpc-web --insecure | grep "Logged in successfully" && argocd account generate-token --account argocd-image-updater --grpc-web --insecure || echo "")

if [ -z "$ARGOCD_AUTH_TOKEN" ]; then
    echo "⚠️  Could not generate auth token automatically. You'll need to do this manually."
    echo "Please run the following commands:"
    echo "1. argocd login localhost:8080 --username admin --password '$ARGOCD_PASSWORD' --grpc-web --insecure"
    echo "2. argocd account generate-token --account argocd-image-updater --grpc-web --insecure"
    echo ""
    echo "Then update your terraform.tfvars file with the token."
else
    echo "✅ Auth token generated successfully!"
    echo "Add this to your terraform.tfvars file:"
    echo "argocd_auth_token = \"$ARGOCD_AUTH_TOKEN\""
fi

# Kill port forward
kill $PF_PID 2>/dev/null || true

# Create example image updater annotations
echo "📝 Creating example image updater configuration..."
cat << 'EOF' > argocd-image-updater-example.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: example-app
  namespace: argocd
  annotations:
    # Enable image updater for this application
    argocd-image-updater.argoproj.io/image-list: nginx=nginx
    # Update strategy: latest, semver, digest
    argocd-image-updater.argoproj.io/nginx.update-strategy: latest
    # Update interval (optional)
    argocd-image-updater.argoproj.io/nginx.update-interval: 1h
    # Allow tags matching this pattern
    argocd-image-updater.argoproj.io/nginx.allow-tags: regexp:^[0-9]+\.[0-9]+\.[0-9]+$
    # Force update even if no changes detected
    argocd-image-updater.argoproj.io/nginx.force-update: "false"
    # Write back to Git (optional)
    argocd-image-updater.argoproj.io/write-back-method: git
spec:
  project: default
  source:
    repoURL: https://github.com/your-repo/your-app
    targetRevision: HEAD
    path: k8s
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
EOF

echo "✅ ArgoCD Image Updater setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Update your terraform.tfvars file with the auth token (if generated)"
echo "2. Run: terraform apply"
echo "3. Check the example configuration in argocd-image-updater-example.yaml"
echo "4. Apply the example to test image updater functionality"
echo ""
echo "🔗 Useful links:"
echo "- ArgoCD Image Updater docs: https://argocd-image-updater.readthedocs.io/"
echo "- Annotation reference: https://argocd-image-updater.readthedocs.io/en/stable/configuration/annotations/" 