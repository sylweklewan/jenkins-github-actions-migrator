resource "kubernetes_manifest" "kserve_selfsigned_issuer" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Issuer"
    metadata = {
      name      = "selfsigned-issuer"
      namespace = data.kubernetes_namespace.kserve.metadata[0].name
      labels = {
        "app.kubernetes.io/managed-by" = "Helm"
      }
      annotations = {
        "meta.helm.sh/release-name"      = "kserve"
        "meta.helm.sh/release-namespace" = "kserve"
      }
    }
    spec = {
      selfSigned = {}
    }
  }
}


resource "kubernetes_manifest" "kserve_webhook_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "serving-cert"
      namespace = data.kubernetes_namespace.kserve.metadata[0].name
      labels = {
        "app.kubernetes.io/managed-by" = "Helm"
      }
      annotations = {
        "meta.helm.sh/release-name"      = "kserve"
        "meta.helm.sh/release-namespace" = "kserve"
      }
    }
    spec = {
      secretName  = "kserve-webhook-server-cert"
      duration    = "8760h" # 1 year
      renewBefore = "720h"  # 30 days before expiry

      subject = {
        organizations = ["KServe"]
      }

      commonName = "kserve-webhook-server-service.kserve.svc"
      dnsNames = [
        "kserve-webhook-server-service.kserve.svc",
        "kserve-webhook-server-service",
      ]

      issuerRef = {
        name = "selfsigned-issuer"
        kind = "Issuer"
      }
    }
  }

  depends_on = [kubernetes_manifest.kserve_selfsigned_issuer]
}



