module "translator_model_serving" {
  source = "./modules/model-serving"
  namespace = "kserve"
  model = var.model
  model_storage_size = var.model_storage_size
  model_local_path = "/home/user/models"
  node_name = ["4d37decc-54d9-4baa-871a-72b0bf11658d"]
  inference_node_port = 30080
  memory_limit = "8Gi"
}

module "embedding_model_serving" {
  source = "./modules/model-serving"
  namespace = "kserve"
  model = var.embedding_model
  model_storage_size = var.model_storage_size
  model_local_path = "/home/user/models"
  node_name = ["4d37decc-54d9-4baa-871a-72b0bf11658d"]
  inference_node_port = 30090
  #inference_service_args = ["--task=text_embedding", "--backend=huggingface"]  
  inference_service_args = ["--task=embed"]  
  memory_limit = "3Gi"
}

