terraform {
  backend "azurerm" {
    resource_group_name   = "terraform-backend-jcuwxn"
    storage_account_name  = "tfstatejcuwxn"
    container_name        = "tfstate"
    key                  = "03-containerapp/terraform.tfstate.json"
  }
}
