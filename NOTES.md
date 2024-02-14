# Terraform

```terraform
resource "azurerm_resource_group" "example" {
  name     = "rg-gpk140224-test"
  location = "UK South"
}


resource "azurerm_storage_account" "example" {
  name                          = "sagpk140214test"
  resource_group_name           = azurerm_resource_group.example.name
  location                      = azurerm_resource_group.example.location
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  public_network_access_enabled = true
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_virtual_network" "example" {
    name                = "vnet-gpk140224-test"
    resource_group_name = azurerm_resource_group.example.name
    location            = azurerm_resource_group.example.location
    address_space       = ["10.0.0.0/16"]
}
```

# Determine if resource is tainted

```powershell
terraform show -json | ConvertFrom-Json | % { $_.values.root_module.resources } | select -Property address, tainted
```

```
address                         tainted
-------                         -------
azurerm_resource_group.example
azurerm_storage_account.example
azurerm_virtual_network.example
```

```powershell
tf taint azurerm_storage_account.example
```

```powershell
terraform show -json | ConvertFrom-Json | % { $_.values.root_module.resources } | select -Property address, tainted
```

```
address                         tainted
-------                         -------
azurerm_resource_group.example
azurerm_storage_account.example True
azurerm_virtual_network.example
```


```powershell
tf untaint azurerm_storage_account.example
```

```powershell
terraform show -json | ConvertFrom-Json | % { $_.values.root_module.resources } | select -Property address, tainted
```

```
address                         tainted
-------                         -------
azurerm_resource_group.example
azurerm_storage_account.example
azurerm_virtual_network.example
```
