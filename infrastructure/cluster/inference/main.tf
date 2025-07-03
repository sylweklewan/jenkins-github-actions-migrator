# # # KServe with RawDeployment Terraform Module (Minikube-compatible)
data "kubernetes_namespace" "kserve" {
  metadata {
    name = "kserve"
  }
}

# ----------------------
# Set default mode to RawDeployment
# ----------------------
# resource "kubernetes_config_map" "kserve_rawdeployment_config" {
#   metadata {
#     name      = "inferenceservice-config"
#     namespace = data.kubernetes_namespace.kserve.metadata[0].name
#   }

#   data = {
#     deploy = yamlencode({
#       defaultDeploymentMode = "RawDeployment"
#     })
#   }
# }


# resource "kubernetes_manifest" "tensorflow_flowers_inference" {
#   manifest = {
#     apiVersion = "serving.kserve.io/v1beta1"
#     kind       = "InferenceService"
#     metadata = {
#       name      = "tensorflow-flowers"
#       namespace = "kserve"
#     }
#     spec = {
#       predictor = {
#         tensorflow = {
#           storageUri = "gs://kfserving-samples/models/tensorflow/flowers"
#           resources = {
#             limits = {
#               memory = "2Gi"
#             }
#           }
#         }
#       }
#     }
#   }
# }
resource "kubernetes_manifest" "sklearn_iris_inference" {
  manifest = {
    apiVersion = "serving.kserve.io/v1beta1"
    kind       = "InferenceService"
    metadata = {
      name      = "sklearn-iris"
      namespace = data.kubernetes_namespace.kserve.metadata[0].name
    }
    spec = {
      predictor = {
        model = {
          modelFormat = {
            name = "sklearn"
          }
          storageUri = "gs://kfserving-examples/models/sklearn/1.0/model"
        }
      }
    }
  }
}