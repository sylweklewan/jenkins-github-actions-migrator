# # # KServe with RawDeployment Terraform Module (Minikube-compatible)
data "kubernetes_namespace" "kserve" {
  metadata {
    name = "kserve"
  }
}

# resource "helm_release" "kserve_crd" {
#   name       = "kserve-crd"
#   namespace = kubernetes_namespace.kserve.metadata[0].name
#   version    = "v0.15.2"

#   repository = "oci://ghcr.io/kserve/charts"
#   chart      = "kserve-crd"
#   create_namespace = false
# }


# resource "null_resource" "wait_for_cert_manager_webhook" {
#   provisioner "local-exec" {
#     command = <<EOT
#       for i in {1..30}; do
#         kubectl get validatingwebhookconfigurations.admissionregistration.k8s.io cert-manager-webhook -o jsonpath='{.webhooks[0].clientConfig.caBundle}' | grep -q . && break
#         echo "Waiting for cert-manager webhook CA to be available..."
#         sleep 3
#       done
#     EOT
#   }
# }

# , null_resource.wait_for_cert_manager_webhook

# ----------------------
# Install KServe with Istio Gateway
# ----------------------
resource "helm_release" "kserve" {
  name       = "kserve"
  repository = "oci://ghcr.io/kserve/charts"
  chart      = "kserve"
  version    = "v0.15.2"
  namespace = data.kubernetes_namespace.kserve.metadata[0].name
  create_namespace = false

  set= [{
    name  = "kserve.controller.deploymentMode"
    value = "RawDeployment"
  },
  # {
  #   name  = "kserve.controller.gateway.ingressGateway.enableIstio"
  #   value = "true"
  # },
  # {
  #   name  = "kserve.controller.gateway.ingressGateway.istioGateway"
  #   value = "istio-system/istio-ingressgateway"
  # },
  {
    name  = "controllers.servingruntimes.enabled"
    value = "false"
  }
  ]

  depends_on = [kubernetes_manifest.kserve_webhook_certificate] 
}

