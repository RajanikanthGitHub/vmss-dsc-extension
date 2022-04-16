resource "azurerm_virtual_network" "main" {
  name                = "shd-sbx-nrk-uks-vnet"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = data.azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_windows_virtual_machine_scale_set" "main" {
  name                 = "shd-sbx-nrk-vmss"
  resource_group_name  = data.azurerm_resource_group.main.name
  location             = data.azurerm_resource_group.main.location
  sku                  = "Standard_B1s"
  instances            = 1
  admin_password       = "P@55w0rd1234!"
  admin_username       = "adminuser"
  computer_name_prefix = "vmss"

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
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.internal.id
    }
  }
}

resource "azurerm_virtual_machine_scale_set_extension" "example" {
  depends_on = [
    azurerm_windows_virtual_machine_scale_set.main
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
	"ModulesUrl": "../dsc/MMAgent.zip",
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