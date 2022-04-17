resource "azurerm_storage_account" "vmss-sa" {
  name                     = "rajanikanthsa"
  resource_group_name      = data.azurerm_resource_group.main.name
  location                 = data.azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "vmss-sa-container" {
  name                  = "vmss-sa-container"
  storage_account_name  = azurerm_storage_account.vmss-sa.name
  container_access_type = "private"
  depends_on = [
    azurerm_storage_account.vmss-sa
  ]
}

resource "azurerm_storage_blob" "vmss-sa-container-blob" {
  name                   = "vmss-dsc-config"
  storage_account_name   = azurerm_storage_account.vmss-sa.name
  storage_container_name = azurerm_storage_container.vmss-sa-container.name
  type                   = "Block"
  source                 = "${path.module}/../dsc/MMAgent.zip"
  depends_on = [
    azurerm_storage_container.vmss-sa-container
  ]
}

# data "azurerm_storage_account_sas" "vmss-random232" {
#   connection_string = azurerm_storage_account.vmss-sa.primary_connection_string
#   https_only        = false
#   resource_types {
#     service   = false
#     container = false
#     object    = true
#   }
#   services {
#     blob  = true
#     queue = false
#     table = false
#     file  = false
#   }
#   start  = "2018-03-21"
#   expiry = "2028-03-21"
#   permissions {
#     read    = true
#     write   = false
#     delete  = false
#     list    = false
#     add     = false
#     create  = false
#     update  = false
#     process = false
#   }
# }