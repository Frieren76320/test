terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.19.0"
    }
  }

backend "azurerm" {
    resource_group_name  = "rg-asr242-student1"
    storage_account_name = "st6p3yxca25bln94xngx"
    container_name       = "tfstates"
    key                  = "terraform.tfstate"
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

# === Reuse existing resource group ===
data "azurerm_resource_group" "main" {
  name = "rg-asr242-student1"
}

# === Container Group ===
resource "azurerm_container_group" "cg1" {
  name                = "ci-asr242-student1"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  ip_address_type     = "Public"
  dns_name_label      = "ci-asr242-student1"
  os_type             = "Linux"

  image_registry_credential {
    server   = var.acr_server
    username = var.acr_username
    password = var.acr_password
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

# === App Service Plan ===
resource "azurerm_service_plan" "example" {
  name                = "plan-asr242-student1"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = "P1v2"
}

# === Linux Web App ===
resource "azurerm_linux_web_app" "example" {
  name                = "webapp-asr242-student1"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  service_plan_id     = azurerm_service_plan.example.id

  site_config {}
}
