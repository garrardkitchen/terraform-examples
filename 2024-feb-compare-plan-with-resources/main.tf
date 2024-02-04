resource "azurerm_resource_group" "resource_group" {
  for_each = var.resource_groups

  name     = "${var.workstream}-${each.key}-rg"
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "main" {
  for_each = var.resource_groups

  name                = "vnet-${var.workstream}-${each.key}"
  address_space       = [each.value.cidr]
  location            = var.location
  resource_group_name = azurerm_resource_group.resource_group[each.key].name
}

resource "azurerm_subnet" "internal" {
  for_each = var.resource_groups

  name                 = "snet-private"
  resource_group_name  = azurerm_resource_group.resource_group[each.key].name
  virtual_network_name = azurerm_virtual_network.main[each.key].name
  # address_prefixes     = [each.value.snets.private.prefix]
  address_prefixes = [cidrsubnet("${each.value.cidr}", 5, 0)]
}

resource "azurerm_network_interface" "main" {
  for_each = var.resource_groups

  name                = "vm${title(each.key)}Nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.resource_group[each.key].name

  ip_configuration {
    name                          = "snet-private-${each.key}"
    subnet_id                     = azurerm_subnet.internal[each.key].id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "main" {
  for_each = var.resource_groups

  name                  = "mainVM"
  resource_group_name   = azurerm_resource_group.resource_group[each.key].name
  location              = var.location
  size                  = "Standard_DS1_v2"
  admin_username        = "garrard"
  network_interface_ids = [azurerm_network_interface.main[each.key].id]

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

  computer_name = "garrardvm"
  admin_ssh_key {
    username   = "garrard"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  disable_password_authentication = true
}