resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  depends_on = [data.talos_cluster_health.this]

  name              = "argocd"
  chart             = "${path.module}/../applications/argocd"
  namespace         = kubernetes_namespace.argocd.metadata[0].name
  values            = [file("../applications/argocd/values.yaml")]
  dependency_update = true
}

resource "kubernetes_namespace" "sealed_secrets" {
  metadata {
    name = "kubeseal"
  }
}

resource "helm_release" "sealed_secrets" {
  depends_on = [data.talos_cluster_health.this]

  name              = "sealed-secrets"
  chart             = "${path.module}/../applications/sealed-secrets"
  namespace         = kubernetes_namespace.sealed_secrets.metadata[0].name
  values            = [file("../applications/sealed-secrets/values.yaml")]
  dependency_update = true
}
