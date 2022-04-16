# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Create a resource group
data "azurerm_resource_group" "main" {
  name = "shd-sbx-nrk-uks-rsg"
}

data "azurerm_automation_account" "main" {
  name                = "shd-sbx-nrk-automation-account"
  resource_group_name = data.azurerm_resource_group.main.name
}