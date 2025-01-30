resource "random_string" "acr_suffix" {
  length  = 6
  special = false
  upper   = false
}
resource "azurerm_container_registry" "flask_acr" {
  name                = "flaskapp${random_string.acr_suffix.result}" 
  resource_group_name = azurerm_resource_group.flask_container_rg.name
  location            = azurerm_resource_group.flask_container_rg.location
  sku                 = "Basic"       # Change to "Standard" or "Premium" if needed
  admin_enabled       = true          # Enables admin user (optional)
}
