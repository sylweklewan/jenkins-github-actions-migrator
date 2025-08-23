variable "namespace" {
  description = "namespace name to provision inference service"
  type        = string
}

variable "model" {
  description = "model name to served"
  type        = string
}

variable "model_storage_size" {
  description = "storage size to mode"
  type        = string
}

variable "model_local_path" {
  description = "path on the node where model is stored"
  type        = string
}

variable "node_name" {
  description = "name of node where model is stored"
  type        = list(string)
}

variable "inference_service_args" {
  description = "additional arguments to be passed to modele sering process"
  type        = list(string)
  default     = []
}

variable "inference_node_port" {
  description = "node port where inference service will be exposed"
  type        = number
}

variable "memory_limit" {
  description = "memory available for model serving pod"
  type        = string
}