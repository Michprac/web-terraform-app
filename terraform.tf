terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  skip_provider_registration = true # This is only required when the User, Service Principal, or Identity running Terraform lacks the permissions to register Azure Resource Providers.
  features {}
}

resource "azurerm_resource_group" "mentorship-rg" {
  name     = "mentorship-rg-terr"
  location = "West Europe"
}


resource "azurerm_virtual_network" "mentorship-vnet" {
  name                = "mentorship-vnet-terr"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.mentorship-rg.location
  resource_group_name = azurerm_resource_group.mentorship-rg.name
}

resource "azurerm_subnet" "mentorship-subnet" {
  name                 = "mentorship-subnet-terr"
  resource_group_name  = azurerm_resource_group.mentorship-rg.name
  virtual_network_name = azurerm_virtual_network.mentorship-vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "example" {
  name                = "example-nic"
  location            = azurerm_resource_group.mentorship-rg.location
  resource_group_name = azurerm_resource_group.mentorship-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.mentorship-subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "mentorship-vm" {
  name                = "mentorship-vm-terr"
  resource_group_name = azurerm_resource_group.mentorship-rg.name
  location            = azurerm_resource_group.mentorship-rg.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.example.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("C:\\Users\\asus\\.ssh\\mentorship_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
