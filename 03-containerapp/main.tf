# Configure the AzureRM provider
provider "azurerm" {
  # Enables the default features of the provider
  features {}
}

# Data source to fetch details of the primary subscription
data "azurerm_subscription" "primary" {}

# Data source to fetch the details of the current Azure client
data "azurerm_client_config" "current" {}

# Resource group for the project

data "azurerm_resource_group" "flask_container_rg" {
  name = "flask-container-rg"
}

