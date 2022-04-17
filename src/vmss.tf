resource "azurerm_windows_virtual_machine_scale_set" "main" {
  name                 = "shd-sbx-nrk-vmss"
  resource_group_name  = data.azurerm_resource_group.main.name
  location             = data.azurerm_resource_group.main.location
  sku                  = "Standard_DS1_v2"
  instances            = 2
  admin_password       = "P@55w0rd1234!"
  admin_username       = "adminuser"
  computer_name_prefix = "vmss"
  overprovision        = false

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter-Server-Core"
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
      load_balancer_inbound_nat_rules_ids    = [azurerm_lb_nat_pool.lbnatpool.id]
      public_ip_address {
        name                = "PubicIPAddress"
        public_ip_prefix_id = azurerm_public_ip_prefix.pip-prefix.id
      }
    }
  }
}


resource "azurerm_virtual_machine_scale_set_extension" "main" {
  depends_on = [
    azurerm_windows_virtual_machine_scale_set.main,
    data.azurerm_automation_account.main
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
	"ModulesUrl": "${var.dsc_module_path}",
	"ConfigurationFunction": "MMAgent.ps1\\MMAgent",
	"Properties": {
      "RegistrationKey": {
        "UserName": "PLACEHOLDER_DONOTUSE",
        "Password": "PrivateSettingsRef:registrationKeyPrivate"
      },
      "RegistrationURL": "${data.azurerm_automation_account.main.endpoint}",
      "NodeConfigurationName": "${var.dsc_config}",
      "ConfigurationModeFrequencyMins": 15,
      "forceUpdateTag": "3",
      "RefreshFrequencyMins": 30,
      "RebootNodeIfNeeded": true,
      "ActionAfterReboot": "continueConfiguration",
      "AllowModuleOverwrite": true
    }
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