# KServe with RawDeployment Terraform Module (Minikube-compatible)



# ----------------------
# Install KServe
# ----------------------
resource "helm_release" "kserve" {
  name             = "kserve"
  repository       = "https://kserve.github.io/helm-charts"
  chart            = "kserve"
  namespace        = "kserve"
  create_namespace = true
  version          = "0.15.0"

  set = [{
    name  = "ingress.gateway"
    value = "istio"
    },
    {
      name  = "knative.enabled"
      value = "false" # ensure KServe doesn't expect Knative
  }]

  depends_on = [helm_release.istio_ingressgateway]
}

# ----------------------
# Set default mode to RawDeployment + disable KServe ingress
# ----------------------
resource "kubernetes_config_map" "kserve_rawdeployment_config" {
  metadata {
    name      = "inferenceservice-config"
    namespace = "kserve"
  }

  data = {
    deploy = yamlencode({
      defaultDeploymentMode = "RawDeployment"
    })
    ingress = yamlencode({
      ingressGateway = ""
      ingressService = ""
    })
  }

  depends_on = [helm_release.kserve]
}

# ----------------------
# Optional: Custom Istio Gateway and VirtualService
# ----------------------
resource "kubernetes_manifest" "custom_gateway" {
  manifest = {
    apiVersion = "networking.istio.io/v1beta1"
    kind       = "Gateway"
    metadata = {
      name      = "my-custom-gateway"
      namespace = "istio-system"
    }
    spec = {
      selector = {
        istio = "ingressgateway"
      }
      servers = [{
        port = {
          number   = 80
          name     = "http"
          protocol = "HTTP"
        }
        hosts = ["*"]
      }]
    }
  }
  depends_on = [helm_release.istio_ingressgateway]
}

resource "kubernetes_manifest" "custom_virtual_service" {
  manifest = {
    apiVersion = "networking.istio.io/v1beta1"
    kind       = "VirtualService"
    metadata = {
      name      = "my-model-vs"
      namespace = "default"
    }
    spec = {
      hosts    = ["my-model.example.com"]
      gateways = ["istio-system/my-custom-gateway"]
      http = [{
        match = [{
          uri = {
            prefix = "/v1/models/my-model"
          }
        }]
        rewrite = {
          uri = "/"
        }
        route = [{
          destination = {
            host = "my-model-predictor-default.default.svc.cluster.local"
            port = {
              number = 80
            }
          }
        }]
      }]
    }
  }
  depends_on = [kubernetes_manifest.custom_gateway]
}

# ----------------------
# InferenceService Resource (Terraform-managed RawDeployment)
# ----------------------
resource "kubernetes_manifest" "inference_service" {
  manifest = {
    apiVersion = "serving.kserve.io/v1beta1"
    kind       = "InferenceService"
    metadata = {
      name      = "my-model"
      namespace = "default"
    }
    spec = {
      predictor = {
        deploymentMode = "RawDeployment"
        containers = [{
          name  = "kserve-container"
          image = "docker.io/pytorch/torchserve:latest"
          ports = [{
            containerPort = 8080
          }]
          args = ["torchserve", "--start", "--ncs", "--model-store", "/models", "--models", "mnist.mar"]
          volumeMounts = [{
            name      = "model-store"
            mountPath = "/models"
          }]
        }]
        volumes = [{
          name     = "model-store"
          emptyDir = {}
        }]
      }
    }
  }
  depends_on = [helm_release.kserve]
}
