data "kubernetes_namespace" "kserve" {
  metadata {
    name = "kserve"
  }
}

resource "helm_release" "kserve" {
  name             = "kserve"
  repository       = "oci://ghcr.io/kserve/charts"
  chart            = "kserve"
  version          = "v0.15.2"
  namespace        = data.kubernetes_namespace.kserve.metadata[0].name
  create_namespace = false

  set = [{
    name  = "kserve.controller.deploymentMode"
    value = "RawDeployment"
    },
    {
      name  = "controllers.servingruntimes.enabled"
      value = "false"
    }
  ]

  depends_on = [kubernetes_manifest.kserve_webhook_certificate]
}

