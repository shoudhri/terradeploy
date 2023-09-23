provider "azurerm" {
  features {}
}

# Variables for Existing VNet and Subnet
variable "existing_vnet_name" {
  description = "Name of the existing VNet"
  type        = string
}

variable "existing_vnet_rg" {
  description = "Resource Group of the existing VNet"
  type        = string
}

variable "existing_subnet_name" {
  description = "Name of the existing subnet within the VNet"
  type        = string
}

# Reference the Existing VNet
data "azurerm_virtual_network" "existing_vnet" {
  name                = var.existing_vnet_name
  resource_group_name = var.existing_vnet_rg
}

# Reference the Specific Subnet
data "azurerm_subnet" "existing_subnet" {
  name                 = var.existing_subnet_name
  virtual_network_name = var.existing_vnet_name
  resource_group_name  = var.existing_vnet_rg
}

# Resource Group for VM
resource "azurerm_resource_group" "rg" {
  name     = "genplaytesting"
  location = "centralindia"  # Adjust to your preferred region or use data.azurerm_virtual_network.existing_vnet.location
}

# Network Interface
resource "azurerm_network_interface" "nic" {
  name                = "myNIC"
  location            = data.azurerm_virtual_network.existing_vnet.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.existing_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Ubuntu 22 LTS Virtual Machine
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "myVM"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_DS1_v2"  # Adjust to your preferred VM size

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "22_04-lts"
    version   = "latest"
  }

  computer_name  = "myvm"
  admin_username = "santhosh"
  admin_password = "Imagine@123!"  # Change this to a strong password

  network_interface_ids = [azurerm_network_interface.nic.id]
}
