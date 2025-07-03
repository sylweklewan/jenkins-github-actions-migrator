variable "kubeconfig_path" {
  type        = string
  description = "Path to kubeconfig file"
}

variable "host_ip" {
  type = string
  description = "machine ip where cluster is running"
}

variable "inference_port" {
  type = number
  description = "port on which inference service is listenning"
}

variable "model" {
  description = "The name of the model to call"
  type        = string
}

variable "prompt" {
  description = "The input payload or prompt for the model"
  type        = string
}