locals {
  jenkins_manifest = var.deploy_apps ? yamldecode(file("${path.module}/jenkins-app.yaml")) : null
}

resource "kubernetes_manifest" "jenkins_app" {
  count    = var.deploy_apps ? 1 : 0
  manifest = local.jenkins_manifest
}

locals {
  postgres_manifest = var.deploy_apps ? yamldecode(file("${path.module}/postgres-app.yaml")) : null
}

resource "kubernetes_manifest" "postgres_app" {
  count    = var.deploy_apps ? 1 : 0
  manifest = local.postgres_manifest
}

