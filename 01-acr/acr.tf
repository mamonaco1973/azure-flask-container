resource "azurerm_container_registry" "flask_acr" {
  name                = "flaskapp${substr(data.azurerm_client_config.current.subscription_id, 0, 6)}" 
  resource_group_name = azurerm_resource_group.flask_container_rg.name
  location            = azurerm_resource_group.flask_container_rg.location
  sku                 = "Basic"       # Change to "Standard" or "Premium" if needed
  admin_enabled       = true          # Enables admin user (optional)
}
