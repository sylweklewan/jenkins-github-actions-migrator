module "translator_model_serving" {
  source              = "./modules/model-serving-vllm"
  namespace           = "kserve"
  model               = var.model
  model_storage_size  = var.model_storage_size
  model_local_path    = "/home/user/models"
  node_name           = [var.node_name]
  inference_service_args = ["--gpu_memory_utilization=0.9"]
  inference_node_port = 30080
  memory_limit        = "16Gi"
}

module "embedding_model_serving" {
source = "./modules/model-serving"
namespace = "kserve"
model = var.embedding_model
model_storage_size = var.model_storage_size
model_local_path = "/home/user/models"
node_name = [var.node_name]
inference_node_port = 30090
inference_service_args = ["--task=embed"]
memory_limit = "3Gi"
}

module "vector_database" {
source = "./modules/vector-database"
namespace = "kserve"
vector_database = var.vector_database
node_name = [var.node_name]
vector_database_local_path = "/home/user/vector_db"
vector_database_storage_size = var.vector_database_storage_size
vector_database_grpc_node_port = 30070
vector_database_http_node_port = 30048
}