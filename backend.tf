terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-n01649908-RG"
    storage_account_name = "tfstaten01649908sa"
    container_name       = "tfstatefiles"
    key                  = "terraform.tfstate"
  }
}

