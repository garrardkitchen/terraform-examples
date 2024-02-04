resource "azurerm_resource_group" "resource_group" {
  name     = "${var.workstream}-rg"
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "main" {
  name                = "mainVNet"
  address_space       = [cidrsubnet("${var.region1cidr}", 2, 0)]
  location            = var.location
  resource_group_name = azurerm_resource_group.resource_group.name
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [cidrsubnet("${var.region1cidr}", 5, 0)]
}

resource "azurerm_network_interface" "main" {
  name                = "mainNic"
  location            = var.location
  resource_group_name = azurerm_resource_group.resource_group.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "main" {
  name                = "mainVM"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = var.location
  size                = "Standard_DS1_v2"
  admin_username      = "garrard"
  network_interface_ids = [azurerm_network_interface.main.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  computer_name  = "garrardvm"
  admin_ssh_key {
    username   = "garrard"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  disable_password_authentication = true
}