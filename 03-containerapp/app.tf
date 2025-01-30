resource "azurerm_container_app_environment" "flask_env" {
  name                = "flask-env"
  resource_group_name = data.azurerm_resource_group.flask_container_rg.name
  location            = data.azurerm_resource_group.flask_container_rg.location
}

resource "azurerm_user_assigned_identity" "containerapp" {
  location            = data.azurerm_resource_group.flask_container_rg.location
  name                = "containerappmi"
  resource_group_name = data.azurerm_resource_group.flask_container_rg.name
}

resource "azurerm_role_assignment" "containerapp" {
  scope                = data.azurerm_container_registry.flask_acr.id
  role_definition_name = "acrpull"
  principal_id         = azurerm_user_assigned_identity.containerapp.principal_id
}

resource "azurerm_container_app" "flask_container_app" {
  name                         = "flask-container-app"
  resource_group_name          = data.azurerm_resource_group.flask_container_rg.name
  container_app_environment_id = azurerm_container_app_environment.flask_env.id

  revision_mode = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.containerapp.id]
  }

  registry {
    server   = data.azurerm_container_registry.flask_acr.login_server
    identity = azurerm_user_assigned_identity.containerapp.id
  }

  template {
    container {
      name = "flask-app"
      #image  = "nginx"
      image  = "${data.azurerm_container_registry.flask_acr.name}.azurecr.io/flask-app:flask-app-rc1"
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

      env {
        name  = "AZURE_CLIENT_ID"
        value = azurerm_user_assigned_identity.containerapp.client_id
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

resource "azurerm_cosmosdb_sql_role_assignment" "app_cosmosdb_role" {
  principal_id        = azurerm_user_assigned_identity.containerapp.principal_id   # Managed Identity of the Container App
  role_definition_id  = azurerm_cosmosdb_sql_role_definition.custom_cosmos_role.id # Custom Cosmos DB Role Definition
  scope               = azurerm_cosmosdb_account.candidate_account.id              # Scope (Cosmos DB Account Level)
  account_name        = azurerm_cosmosdb_account.candidate_account.name            # Cosmos DB Account Name
  resource_group_name = data.azurerm_resource_group.flask_container_rg.name        # Resource Group Name
}


