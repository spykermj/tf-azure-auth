terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.39.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
  }

  required_version = "~> 1.5.1"
}
