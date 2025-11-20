
terraform {
  required_version = "= 1.14.0"

  required_providers {
    kind = {
      source  = "tehcyx/kind"
      version = "0.9.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.38"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.1.1"
    }
  }
}

provider "kind" {}

# Assumes your kind cluster context is in ~/.kube/config as "kind-dev-cluster"
provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "kind-dev-cluster"
  #  insecure       = true # 👈 disable cert hostname check

}

provider "helm" {
  kubernetes = {
    config_path    = "~/.kube/config"
    config_context = "kind-dev-cluster"
    # insecure       = true
  }
}
