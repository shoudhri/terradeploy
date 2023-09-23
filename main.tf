resource "azurerm_network_security_group" "nsg" {
  name                = var.networkSecurityGroupName
  location            = var.location
  resource_group_name = var.resource_group_name

  dynamic "security_rule" {
    for_each = var.networkSecurityGroupRules
    content {
      name                        = security_rule.value.name
      priority                    = security_rule.value.priority
      direction                   = security_rule.value.direction
      access                      = security_rule.value.access
      protocol                    = security_rule.value.protocol
      source_port_range           = security_rule.value.source_port_range
      destination_port_range      = security_rule.value.destination_port_range
      source_address_prefix       = security_rule.value.source_address_prefix
      destination_address_prefix  = security_rule.value.destination_address_prefix
    }
  }

  tags = {
    test = "delete"
  }
}

resource "azurerm_public_ip" "pip" {
  name                = var.publicIpAddressName
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = var.publicIpAddressType
  sku                 = var.publicIpAddressSku

  tags = {
    test = "delete"
  }
}

resource "azurerm_network_interface" "nic" {
  name                = var.networkInterfaceName
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }

  enable_accelerated_networking = var.enableAcceleratedNetworking

  network_security_group_id = azurerm_network_security_group.nsg.id

  tags = {
    test = "delete"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = var.virtualMachineName
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.virtualMachineSize

  network_interface_ids = [azurerm_network_interface.nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.osDiskType
  }

  source_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  computer_name  = var.virtualMachineComputerName
  admin_username = var.adminUsername
  disable_password_authentication = true

  tags = {
    test = "delete"
  }
}

output "adminUsername" {
  value = var.adminUsername
}
