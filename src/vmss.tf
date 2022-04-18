resource "azurerm_windows_virtual_machine_scale_set" "main" {
  name                 = "shd-sbx-nrk-vmss"
  resource_group_name  = data.azurerm_resource_group.main.name
  location             = data.azurerm_resource_group.main.location
  sku                  = "Standard_DS1_v2"
  instances            = 1
  admin_password       = "Srujana_12345678"
  admin_username       = "adminuser"
  computer_name_prefix = "vmss"
  overprovision        = false

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "vmss-nic"
    primary = true

    ip_configuration {
      name                                   = "internal"
      primary                                = true
      subnet_id                              = azurerm_subnet.internal.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.vmss_lb_backend_pool.id]
    }
  }
  depends_on = [
    azurerm_virtual_network.main
  ]
}


resource "azurerm_virtual_machine_scale_set_extension" "main" {
  depends_on = [
    azurerm_windows_virtual_machine_scale_set.main,
    data.azurerm_automation_account.main,
    azurerm_storage_account.vmss-sa
  ]
  name                         = "Microsoft.Powershell.DSC"
  virtual_machine_scale_set_id = azurerm_windows_virtual_machine_scale_set.main.id
  publisher                    = "Microsoft.Powershell"
  type                         = "DSC"
  type_handler_version         = "2.9"
  auto_upgrade_minor_version   = false
  settings                     = <<SETTINGS
  {
    "WmfVersion": "latest",
    "modulesUrl": "${var.dsc_module_path}",
    "configurationFunction": "MMAgent.ps1\\MMAgent",      
    "Properties": [{
        "Name": "RegistrationKey",
        "Value": {
          "UserName": "PLACEHOLDER_DONOTUSE",
          "Password": "PrivateSettingsRef:registrationKeyPrivate"
        },
        "TypeName": "System.Management.Automation.PSCredential"
      },
      {
        "Name": "RegistrationUrl",
        "Value": "${data.azurerm_automation_account.main.endpoint}",
        "TypeName": "System.String"
      },
      {
        "Name": "NodeConfigurationName",
        "Value": "${var.dsc_config}",
        "TypeName": "System.String"
      },
      {
        "Name": "ConfigurationMode",
        "Value": "${var.dsc_config_mode}",
        "TypeName": "System.String"
      }]
  }
  SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
  {
    "Items": {
      "registrationKeyPrivate" : "${data.azurerm_automation_account.main.primary_key}"
    }
  }
  PROTECTED_SETTINGS
}