resource "helm_release" "argocd" {
  depends_on = [data.talos_cluster_health.this]

  name              = "argocd"
  chart             = "${path.module}/../applications/argocd"
  namespace         = "argocd"
  create_namespace  = true
  values            = [file("../applications/argocd/values.yaml")]
  dependency_update = true
}

resource "helm_release" "sealed_secrets" {
  depends_on = [data.talos_cluster_health.this]

  name              = "sealed-secrets"
  chart             = "${path.module}/../applications/sealed-secrets"
  namespace         = "kubeseal"
  create_namespace  = true
  values            = [file("../applications/sealed-secrets/values.yaml")]
  dependency_update = true
}
