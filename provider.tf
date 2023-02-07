terraform {
  required_version = ">=0.12"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "tf_rg"
    storage_account_name = "tfstatecvlwl"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}
provider "github" {
  token = "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"
  owner = "rhamza97"
}
provider "azurerm" {
  features {}
}
