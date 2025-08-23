variable "namespace" {
  type        = string
  description = "namespace where vector database need to be deployed"
}

variable "vector_database" {
  type        = string
  description = "name of vector database"
}

variable "vector_database_storage_size" {
  type        = string
  description = "storage size for vector database"
}

variable "vector_database_local_path" {
  type        = string
  description = "path on node for where vector is stored"
}

variable "node_name" {
  type        = list(string)
  description = "name of node"
}

variable "vector_database_http_node_port" {
  type        = number
  description = "port where vector db is acception http calls"
}

variable "vector_database_grpc_node_port" {
  type        = number
  description = "port where vector db is acception grpc calls"
}
