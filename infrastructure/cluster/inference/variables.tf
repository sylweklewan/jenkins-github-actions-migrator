variable "kubeconfig_path" {
  type        = string
  description = "Path to kubeconfig file"
}

variable "host_ip" {
  type        = string
  description = "machine ip where cluster is running"
}

variable "inference_port" {
  type        = number
  description = "port on which inference model serving is listenning"
}

variable "model" {
  description = "The name of the model to call"
  type        = string
}

variable "prompt" {
  description = "The sample inputs payload or prompt for the model"
  type        = map(string)
}

variable "max_tokens" {
  type        = number
  description = "Max number of tokens in response"
}

variable "jenkins_pipeline_files" {
  type        = map(string)
  description = "contains path to jenkins files that should be translated"
}

variable "jenkins_pipeline_prompt_start" {
  type        = string
  description = "prompt introduction to jenkins file"
}

variable "model_storage_size" {
  type        = string
  description = "size of pv holding model"
}

variable "embedding_model" {
  description = "model to be used to generate embeddings"
  type        = string
}

variable "embedding_port" {
  type        = number
  description = "port on which embeddings model serving is listenning"
}

variable "vector_database" {
  type        = string
  description = "name of vector database"
}

variable "vector_database_storage_size" {
  type        = string
  description = "storage size for vector database"
}

variable "node_name" {
  type        = string
  description = "name of node to set up storage pv"
}