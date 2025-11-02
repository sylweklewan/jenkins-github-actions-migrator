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

resource "kubernetes_deployment" "model_serving" {
  metadata {
    name = join("-", [var.model, "deploy"])
    labels = {
      app = var.model
    }
    namespace = data.kubernetes_namespace.kserve.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = var.model
      }
    }

    template {
      metadata {
        labels = {
          app = var.model
        }
      }

      spec {
        runtime_class_name = "nvidia"
        container {
          name  = "vllm"
          image = "vllm/vllm-openai:latest"

          args = concat([
            "--model=/mnt/models/${var.model}"
            #,
            #"--gpu_memory_utilization=0.5"
          ], var.inference_service_args)
          
          port {
            container_port = 8000
          }

          env {
            name = "CUDA_VISIBLE_DEVICES"
            value = "0"
          }


          env {
            name = "VLLM_USE_FLASH_ATTN"
            value = "0"
          }



          resources {
            limits = {
              memory           = var.memory_limit
              cpu              = "1"
              "nvidia.com/gpu" = "1"
            }
            requests = {
              memory           = var.memory_limit
              cpu              = "1"
              "nvidia.com/gpu" = "1"
            }
          }

          volume_mount {
            name       = "model-storage"
            mount_path = "/mnt/models"
          }
        }

        volume {
          name = "model-storage"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.model_pvc.metadata[0].name
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
      "app" = "${var.model}"
    }

    type = "NodePort"

    port {
      port        = 80
      target_port = 8000
      node_port   = var.inference_node_port
    }
  }
}