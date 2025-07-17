# # # KServe with RawDeployment Terraform Module (Minikube-compatible)
data "kubernetes_namespace" "kserve" {
  metadata {
    name = "kserve"
  }
}



resource "kubernetes_persistent_volume" "nextcoder_coder_pv" {
  metadata {
    name = "nextcoder-coder-pv"

    labels = {
      type = "local"
    }
  }

  spec {
    capacity = {
      storage = "30Gi"
    }

    persistent_volume_source {
      local {
            path = "/home/user/models"
      }
    }

    access_modes                     = ["ReadWriteOnce"]
    persistent_volume_reclaim_policy = "Retain"
    storage_class_name               = "local-storage"
    volume_mode = "Filesystem"



    node_affinity {
      required {
        node_selector_term {
          match_expressions {
            key      = "kubernetes.io/hostname"
            operator = "In"
            values   = ["4d37decc-54d9-4baa-871a-72b0bf11658d"]  # replace this with your actual node name
          }
        }
      }
    }
  }
}


resource "kubernetes_persistent_volume_claim" "nextcoder_coder_pvc" {
  metadata {
    name      = "nextcoder-coder-pvc"
    namespace = data.kubernetes_namespace.kserve.metadata[0].name
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = "30Gi"
      }
    }

    storage_class_name = "local-storage"
    volume_name        = kubernetes_persistent_volume.nextcoder_coder_pv.metadata[0].name
  }
}

resource "kubernetes_manifest" "nextcoder_inference" {
  manifest = {
    apiVersion = "serving.kserve.io/v1beta1"
    kind       = "InferenceService"
    metadata = {
       name      = "nextcoder"
       namespace = data.kubernetes_namespace.kserve.metadata[0].name
    }
    spec = {
      predictor = {
        runtimeClassName = "nvidia"
        model = {
          storageUri = "pvc://nextcoder-coder-pvc/nextcoder/"
          modelFormat = {
            name = "huggingface"
          }
          args = [
            "--model_name=nextcoder",
            "--model_dir=/mnt/models",
            "--trust-remote-code",
          ]
          resources = {
            requests = {
              memory = "10Gi"
              cpu = "800m"
              "nvidia.com/gpu" = "1"
            }
            limits = {
              memory = "10Gi"
              cpu = "900m"
              "nvidia.com/gpu" = "1"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "nextcoder_coder_nodeport" {
  metadata {
    name      = "nextcoder-coder-nodeport"
    namespace = data.kubernetes_namespace.kserve.metadata[0].name
  }

  spec {
    selector = {
      "serving.kserve.io/inferenceservice" = "nextcoder"
    }

    type = "NodePort" 

    port {
      port        = 80        # Exposed service port
      target_port = 8080      # Port on the pod (KServe predictor listens on 8080)
      node_port   = 30080     # Optional fixed NodePort (or omit to let k8s assign)
    }
  }
}




# resource "kubernetes_manifest" "nextcoder_coder_inference" {
#   manifest = {
#     apiVersion = "serving.kserve.io/v1beta1"
#     kind       = "InferenceService"
#     metadata = {
#       name      = "nextcoder-coder"
#       namespace = data.kubernetes_namespace.kserve.metadata[0].name
#     }
#     spec = {
#       predictor = {
#         containers = [
#           {
#             name  = "kserve-container"
#             image = "ghcr.io/huggingface/text-generation-inference:latest" 
#             args = [
#               "--model-id=/mnt/models",
#               "--revision=local",
#               "--trust-remote-code",
#               "--port=8080",
#             ]

#             ports = [
#               {
#                 containerPort = 8080
#               }
#             ]

#             resources = {
#               requests = {
#                 memory = "10Gi"
#                 cpu = "800m"
#                 "nvidia.com/gpu" = "1"
#               }

#               limits = {
#                 memory = "10Gi"
#                 cpu = "900m"
#                 "nvidia.com/gpu" = "1"
#               }
#             }

#             volumeMounts = [
#               {
#                 name      = "model-volume"
#                 mountPath = "/mnt/models"
#               }
#             ]
#           }
#         ]
#         runtimeClassName = "nvidia"
#         volumes = [
#           {
#             name = "model-volume"
#             persistentVolumeClaim = {
#               claimName = kubernetes_persistent_volume_claim.nextcoder_coder_pvc.metadata[0].name
#             }
#           }
#         ]
#       }
#     }
#   }
# }


# resource "kubernetes_service" "nextcoder_coder_nodeport" {
#   metadata {
#     name      = "nextcoder-coder-nodeport"
#     namespace = data.kubernetes_namespace.kserve.metadata[0].name
#   }

#   spec {
#     selector = {
#       "serving.kserve.io/inferenceservice" = "nextcoder-coder"
#     }

#     type = "NodePort" 

#     port {
#       port        = 80        # Exposed service port
#       target_port = 8080      # Port on the pod (KServe predictor listens on 8080)
#       node_port   = 30080     # Optional fixed NodePort (or omit to let k8s assign)
#     }
#   }
# }



# Sample inference
# resource "kubernetes_manifest" "sklearn_iris_inference" {
#   manifest = {
#     apiVersion = "serving.kserve.io/v1beta1"
#     kind       = "InferenceService"
#     metadata = {
#       name      = "sklearn-iris"
#       namespace = data.kubernetes_namespace.kserve.metadata[0].name
#     }
#     spec = {
#       predictor = {
#         model = {
#           modelFormat = {
#             name = "sklearn"
#           }
#           storageUri = "gs://kfserving-examples/models/sklearn/1.0/model"
#         }
#       }
#     }
#   }
# }

# resource "kubernetes_service" "sklearn_iris_nodeport" {
#   metadata {
#     name      = "sklearn-iris-nodeport"
#     namespace = data.kubernetes_namespace.kserve.metadata[0].name
#   }

#   spec {
#     selector = {
#       "serving.kserve.io/inferenceservice" = "sklearn-iris"
#     }

#     type = "NodePort" 

#     port {
#       port        = 80        # Exposed service port
#       target_port = 8080      # Port on the pod (KServe predictor listens on 8080)
#       node_port   = 30080     # Optional fixed NodePort (or omit to let k8s assign)
#     }
#   }
# }

# OLD TO REMOVE
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