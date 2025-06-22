# ----------------------
# Install Cert-Manager (Required by KServe webhook)
# ----------------------
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

