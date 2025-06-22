# ----------------------
# TLS Cert + Secret (Self-signed for dev)
# ----------------------
resource "tls_private_key" "kserve_tls_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "kserve_tls_cert" {
  private_key_pem = tls_private_key.kserve_tls_key.private_key_pem

  subject {
    common_name  = "my-model.example.com"
    organization = "KServe"
  }

  validity_period_hours = 8760
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]

  dns_names = ["my-model.example.com"]
}

resource "kubernetes_secret" "kserve_tls_secret" {
  metadata {
    name      = "my-secret"
    namespace = kubernetes_namespace.kserve.metadata[0].name
  }

  data = {
    "tls.crt" = base64encode(tls_self_signed_cert.kserve_tls_cert.cert_pem)
    "tls.key" = base64encode(tls_private_key.kserve_tls_key.private_key_pem)
  }

  type = "kubernetes.io/tls"
}