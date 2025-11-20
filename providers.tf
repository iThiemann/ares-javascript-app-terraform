
terraform {
  required_version = "= 1.14.0"

  required_providers {
    kind = {
      source  = "tehcyx/kind"
      version = "0.9"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13"
    }
  }
}

provider "kind" {}

# Assumes your kind cluster context is in ~/.kube/config as "kind-dev-cluster"
provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "kind-dev-cluster"
}

provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = "kind-dev-cluster"
  }
}
