terraform {
  backend "azurerm" {
    resource_group_name   = "terraform-backend-c4da0g"
    storage_account_name  = "tfstatec4da0g"
    container_name        = "tfstate"
    key                  = "03-containerapp/terraform.tfstate.json"
  }
}
