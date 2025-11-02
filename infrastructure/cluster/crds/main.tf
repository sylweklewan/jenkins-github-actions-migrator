data "kubernetes_namespace" "kserve" {
  metadata {
    name = "kserve"
  }
}

resource "helm_release" "kserve_crd" {
  name      = "kserve-crd"
  namespace = data.kubernetes_namespace.kserve.metadata[0].name
  version   = "v0.15.2"

  repository       = "oci://ghcr.io/kserve/charts"
  chart            = "kserve-crd"
  create_namespace = false
}

resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "v1.15.0"
  namespace        = "cert-manager"
  create_namespace = true

  set = [
    {
      name  = "installCRDs"
      value = "true"
    }
  ]
}