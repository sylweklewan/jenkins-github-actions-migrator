terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.7.1"
    }

    tls = {
      version = ">= 4.1.0"
    }
  }
}

provider "kubernetes" {
  config_path    = var.kubeconfig_path
  config_context = "a100"
}

provider "helm" {
  kubernetes = {
    config_path = var.kubeconfig_path
  }
}