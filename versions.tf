terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    null = {
      source = "hashicorp/null"
    }
    random = {
      source = "hashicorp/random"
    }
    sdm = {
      source = "strongdm/sdm"
      version = "1.0.8"
    }
  }
  required_version = ">= 0.13"
}
