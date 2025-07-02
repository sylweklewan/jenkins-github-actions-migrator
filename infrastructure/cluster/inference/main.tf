# # # KServe with RawDeployment Terraform Module (Minikube-compatible)
data "kubernetes_namespace" "kserve" {
  metadata {
    name = "kserve"
  }
}

# ----------------------
# Set default mode to RawDeployment
# ----------------------
resource "kubernetes_config_map" "kserve_rawdeployment_config" {
  metadata {
    name      = "inferenceservice-config"
    namespace = data.kubernetes_namespace.kserve.metadata[0].name
  }

  data = {
    deploy = yamlencode({
      defaultDeploymentMode = "RawDeployment"
    })
  }
}


resource "kubernetes_manifest" "my_model_inferenceservice" {
  manifest = {
    apiVersion = "serving.kserve.io/v1beta1"
    kind       = "InferenceService"
    metadata = {
      name      = "my-model"
      namespace = "kserve"
    }
    spec = {
      predictor = {
        tensorflow = {
          storageUri = "gs://kfserving-samples/models/tensorflow/flowers"
          resources = {
            limits = {
              cpu    = "1"
              memory = "2Gi"
            }
          }
        }
      }
    }
  }
}
