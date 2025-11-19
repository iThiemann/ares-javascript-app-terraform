
terraform {
  required_version = "= 1.14.0"

  required_providers {
    kind = {
      source  = "tehcyx/kind"
      version = "0.9"
    }
  }
}

provider "kind" {}
