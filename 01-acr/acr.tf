# Generates a random string of 6 lowercase alphanumeric characters.
# Used to ensure uniqueness in the ACR name.
resource "random_string" "acr_suffix" {
  length  = 6     # The length of the generated string (adjust as needed)
  special = false # No special characters allowed (only alphanumeric)
  upper   = false # Ensure all characters are lowercase to avoid issues
}

# Defines an Azure Container Registry (ACR) for storing Docker container images.
resource "azurerm_container_registry" "flask_acr" {
  # ACR name must be globally unique across all Azure regions.
  # Uses the generated random suffix to prevent name collisions.
  name = "flaskapp${random_string.acr_suffix.result}"

  # The Azure Resource Group where the ACR will be deployed.
  # Must already exist before this deployment.
  resource_group_name = azurerm_resource_group.flask_container_rg.name

  # The Azure region where the ACR will be hosted.
  # Must match the Resource Group's location for consistency.
  location = azurerm_resource_group.flask_container_rg.location

  # Specifies the SKU (pricing tier) for the ACR.
  # - "Basic" is the cheapest option with limited capabilities.
  # - "Standard" provides increased storage and replication.
  # - "Premium" enables geo-replication and advanced security features.
  sku = "Basic"
}
