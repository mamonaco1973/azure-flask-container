resource "azurerm_container_app_environment" "flask_env" {
  name                = "flask-env"
  resource_group_name = data.azurerm_resource_group.flask_container_rg.name
  location            = data.azurerm_resource_group.flask_container_rg.location
}

resource "azurerm_container_app" "flask_container_app" {
  name                         = "flask-container-app"
  resource_group_name          = data.azurerm_resource_group.flask_container_rg.name
  container_app_environment_id = azurerm_container_app_environment.flask_env.id

  revision_mode = "Single"

  identity {
    type         = "SystemAssigned"
  }

  template {
    container {
      name = "flask-app"
      image  = "nginx"
      #image  = "${data.azurerm_container_registry.flask_acr.name}.azurecr.io/flask-app:flask-app-rc1"
      cpu    = "0.25"
      memory = "0.5Gi"

      env {
        name  = "COSMOS_ENDPOINT"
        value = azurerm_cosmosdb_account.candidate_account.endpoint
      }

      env {
        name  = "COSMOS_DATABASE_NAME"
        value = "CandidateDatabase"
      }

      env {
        name  = "COSMOS_CONTAINER_NAME"
        value = "Candidates"
      }
    }

    min_replicas = 1
    max_replicas = 3
  }

  ingress {
    external_enabled = true
    target_port      = 8000
    transport        = "auto"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }
}

#Assign the custom Cosmos DB role to the Container App

resource "azurerm_cosmosdb_sql_role_assignment" "app_cosmosdb_role" {
  principal_id        = azurerm_container_app.flask_container_app.identity[0].principal_id  # Principal ID
  role_definition_id  = azurerm_cosmosdb_sql_role_definition.custom_cosmos_role.id    # Role definition ID
  scope               = azurerm_cosmosdb_account.candidate_account.id                 # Scope
  account_name        = azurerm_cosmosdb_account.candidate_account.name               # Cosmos DB account name
  resource_group_name = data.azurerm_resource_group.flask_container_rg.name           # Resource group name
}
