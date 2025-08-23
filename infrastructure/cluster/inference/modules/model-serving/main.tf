data "kubernetes_namespace" "kserve" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_persistent_volume" "model_pv" {
  metadata {
    name = join("-", [var.model, "pv"])

    labels = {
      type = "local"
    }
  }

  spec {
    capacity = {
      storage = var.model_storage_size
    }

    persistent_volume_source {
      local {
        path = var.model_local_path
      }
    }

    access_modes                     = ["ReadWriteOnce"]
    persistent_volume_reclaim_policy = "Retain"
    storage_class_name               = "local-storage"
    volume_mode                      = "Filesystem"

    node_affinity {
      required {
        node_selector_term {
          match_expressions {
            key      = "kubernetes.io/hostname"
            operator = "In"
            values   = var.node_name
          }
        }
      }
    }
  }
}


resource "kubernetes_persistent_volume_claim" "model_pvc" {
  metadata {
    name      = join("-", [var.model, "pvc"])
    namespace = data.kubernetes_namespace.kserve.metadata[0].name
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = var.model_storage_size
      }
    }

    storage_class_name = "local-storage"
    volume_name        = kubernetes_persistent_volume.model_pv.metadata[0].name
  }
}

resource "kubernetes_manifest" "model_serving" {
  manifest = {
    apiVersion = "serving.kserve.io/v1beta1"
    kind       = "InferenceService"
    metadata = {
      name      = var.model
      namespace = data.kubernetes_namespace.kserve.metadata[0].name
    }
    spec = {
      predictor = {
        runtimeClassName = "nvidia"
        model = {
          storageUri = "pvc://${kubernetes_persistent_volume_claim.model_pvc.metadata[0].name}/${var.model}/"
          modelFormat = {
            name = "huggingface"
          }
          args = concat([
            "--model_name=${var.model}",
            "--model_dir=/mnt/models",
            "--trust-remote-code",
          ], var.inference_service_args)
          resources = {
            requests = {
              memory           = var.memory_limit
              cpu              = "1"
              "nvidia.com/gpu" = "1"
            }
            limits = {
              memory           = var.memory_limit
              cpu              = "1"
              "nvidia.com/gpu" = "1"
            }
          }
        }
      }
    }
  }
}


resource "kubernetes_service" "model_nodeport" {
  metadata {
    name      = "${var.model}-nodeport"
    namespace = data.kubernetes_namespace.kserve.metadata[0].name
  }

  spec {
    selector = {
      "serving.kserve.io/inferenceservice" = "${var.model}"
    }

    type = "NodePort"

    port {
      port        = 80
      target_port = 8080
      node_port   = var.inference_node_port
    }
  }
}