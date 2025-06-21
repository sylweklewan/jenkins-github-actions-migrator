terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.7.1"
    }
  }
}

provider "kubernetes" {
  config_path    = var.kubeconfig_path
  config_context = "default"
}

provider "helm" {
  kubernetes = {
    config_path = var.kubeconfig_path
  }
}