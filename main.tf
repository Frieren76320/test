# configurer le provider azuread
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.19.0"
    }
  }
}
 
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  subscription_id = var.subscription_id
}
 
variable "subscription_id" {
  description = "The Azure subscription ID to use for the resources."
  type        = string
  
}
 
data "azurerm_resource_group" "main" {
  name = "rg-asr242-student1"
}
 
resource "azurerm_container_group" "cg1" {
  name                = "ci-asr242-student1"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  ip_address_type     = "Public"
  dns_name_label      = "ci-asr242-student1"
  os_type             = "Linux"
  image_registry_credential {
    server   = "acrasr242teacher.azurecr.io"
    username = "acrasr242teacher"
    password = "jfhjfzCrs5vo5j1P5BsxRvVep33OM3+Ogy8pUdlKyu+ACRB284sY" # Replace with your actual password
  }
 
  container {
    name   = "nginx"
    image  = "acrasr242teacher.azurecr.io/nginx:latest"
    cpu    = "0.5"
    memory = "1.5"
 
    ports {
      port     = 80
      protocol = "TCP"
    }
  }
}