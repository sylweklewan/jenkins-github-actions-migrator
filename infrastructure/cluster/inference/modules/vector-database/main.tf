data "kubernetes_namespace" "kserve" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_persistent_volume" "vector_database_pv" {
  metadata {
    name = join("-", [var.vector_database, "pv"])

    labels = {
      type = "local"
    }
  }

  spec {
    capacity = {
      storage = var.vector_database_storage_size
    }

    persistent_volume_source {
      local {
        path = var.vector_database_local_path
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

resource "kubernetes_persistent_volume_claim" "vector_database_pvc" {
  metadata {
    name      = join("-", [var.vector_database, "pvc"])
    namespace = data.kubernetes_namespace.kserve.metadata[0].name
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = var.vector_database_storage_size
      }
    }

    storage_class_name = "local-storage"
    volume_name        = kubernetes_persistent_volume.vector_database_pv.metadata[0].name
  }
}

resource "kubernetes_deployment" "vector_database" {
  metadata {
    name = join("-", [var.vector_database, "deploy"])
    labels = {
      app = var.vector_database
    }
    namespace = data.kubernetes_namespace.kserve.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = var.vector_database
      }
    }

    template {
      metadata {
        labels = {
          app = var.vector_database
        }
      }

      spec {
        runtime_class_name = "nvidia"
        container {
          name  = join("-", [var.vector_database, "container"])
          image = "qdrant/qdrant:v1.15.0-gpu-nvidia"

          port {
            container_port = 6333
          }

          port {
            container_port = 6334
          }

          resources {
            limits = {
              cpu              = "200m"
              memory           = "1Gi"
              "nvidia.com/gpu" = "1"
            }
            requests = {
              cpu              = "100m"
              memory           = "512Mi"
              "nvidia.com/gpu" = "1"
            }
          }

          volume_mount {
            name       = "vector-db-storage"
            mount_path = "/qdrant/storage"
          }
        }

        volume {
          name = "vector-db-storage"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.vector_database_pvc.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "vector_database_nodeport" {
  metadata {
    name = "${var.vector_database}-nodeport"
    namespace = data.kubernetes_namespace.kserve.metadata[0].name
  }

  spec {
    selector = {
      app = var.vector_database
    }

    type = "NodePort"

    port {
      name        = "http"
      target_port        = 6333
      port = 6333
      node_port = var.vector_database_http_node_port
    }

    port {
      name        = "grpc"
      port        = 6334
      target_port = 6334
      node_port = var.vector_database_grpc_node_port
    }
  }
}
