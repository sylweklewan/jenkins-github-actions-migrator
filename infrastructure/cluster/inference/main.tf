module "translator_model_inference" {
  source = "./modules/model-serving"
  namespace = "kserve"
  model = var.model
  model_storage_size = var.model_storage_size
  model_local_path = "/home/user/models"
  node_name = ["4d37decc-54d9-4baa-871a-72b0bf11658d"]
  inference_node_port = 30080
}

# # # # KServe with RawDeployment
# data "kubernetes_namespace" "kserve" {
#   metadata {
#     name = "kserve"
#   }
# }



# resource "kubernetes_persistent_volume" "model_pv" {
#   metadata {
#     name = join("-", [var.model, "pv"])

#     labels = {
#       type = "local"
#     }
#   }

#   spec {
#     capacity = {
#       storage = var.model_storage_size
#     }

#     persistent_volume_source {
#       local {
#         path = "/home/user/models"
#       }
#     }

#     access_modes                     = ["ReadWriteOnce"]
#     persistent_volume_reclaim_policy = "Retain"
#     storage_class_name               = "local-storage"
#     volume_mode                      = "Filesystem"

#     node_affinity {
#       required {
#         node_selector_term {
#           match_expressions {
#             key      = "kubernetes.io/hostname"
#             operator = "In"
#             values   = ["4d37decc-54d9-4baa-871a-72b0bf11658d"] # replace this with your actual node name
#           }
#         }
#       }
#     }
#   }
# }


# resource "kubernetes_persistent_volume_claim" "model_pvc" {
#   metadata {
#     name      = join("-", [var.model, "pvc"])
#     namespace = data.kubernetes_namespace.kserve.metadata[0].name
#   }

#   spec {
#     access_modes = ["ReadWriteOnce"]

#     resources {
#       requests = {
#         storage = var.model_storage_size
#       }
#     }

#     storage_class_name = "local-storage"
#     volume_name        = kubernetes_persistent_volume.model_pv.metadata[0].name
#   }
# }

# resource "kubernetes_manifest" "translator_model_inference" {
#   manifest = {
#     apiVersion = "serving.kserve.io/v1beta1"
#     kind       = "InferenceService"
#     metadata = {
#       name      = var.model
#       namespace = data.kubernetes_namespace.kserve.metadata[0].name
#     }
#     spec = {
#       predictor = {
#         runtimeClassName = "nvidia"
#         model = {
#           storageUri = "pvc://${kubernetes_persistent_volume_claim.model_pvc.metadata[0].name}/${var.model}/"
#           modelFormat = {
#             name = "huggingface"
#           }
#           args = [
#             "--model_name=${var.model}",
#             "--model_dir=/mnt/models",
#             "--trust-remote-code",
#           ]
#           resources = {
#             requests = {
#               memory           = "10Gi"
#               cpu              = "1"
#               "nvidia.com/gpu" = "1"
#             }
#             limits = {
#               memory           = "10Gi"
#               cpu              = "1"
#               "nvidia.com/gpu" = "1"
#             }
#           }
#         }
#       }
#     }
#   }
# }


# # resource "kubernetes_manifest" "embedding_model_inference" {
# #   manifest = {
# #     apiVersion = "serving.kserve.io/v1beta1"
# #     kind       = "InferenceService"
# #     metadata = {
# #       name      = var.embedding_model
# #       namespace = data.kubernetes_namespace.kserve.metadata[0].name
# #     }
# #     spec = {
# #       predictor = {
# #         runtimeClassName = "nvidia"
# #         model = {
# #           storageUri = "pvc://${kubernetes_persistent_volume_claim.model_pvc.metadata[0].name}/${var.embedding_model}/"
# #           modelFormat = {
# #             name = "huggingface"
# #           }
# #           args = [
# #             "--model_name=${var.model}",
# #             "--model_dir=/mnt/models",
# #             "--trust-remote-code",
# #             "--task=embed"
# #           ]
# #           resources = {
# #             requests = {
# #               memory           = "10Gi"
# #               cpu              = "1"
# #               "nvidia.com/gpu" = "1"
# #             }
# #             limits = {
# #               memory           = "10Gi"
# #               cpu              = "1"
# #               "nvidia.com/gpu" = "1"
# #             }
# #           }
# #         }
# #       }
# #     }
# #   }
# # }

# resource "kubernetes_service" "translator_model_nodeport" {
#   metadata {
#     name      = "${var.model}-nodeport"
#     namespace = data.kubernetes_namespace.kserve.metadata[0].name
#   }

#   spec {
#     selector = {
#       "serving.kserve.io/inferenceservice" = "${var.model}"
#     }

#     type = "NodePort"

#     port {
#       port        = 80
#       target_port = 8080
#       node_port   = 30080
#     }
#   }
# }