resource "azurerm_resource_group" "rs" {
  name     = var.rg
  location = var.rg_location
}
resource "azurerm_virtual_network" "tf_network" {
  name                = var.ni_name
  resource_group_name = azurerm_resource_group.rs.name
  location            = azurerm_resource_group.rs.location
  address_space       = ["10.0.0.0/16"]
}
resource "azurerm_subnet" "subnet" {
  name                 = "tf_subnet"
  resource_group_name  = var.rg
  virtual_network_name = var.ni_name
  address_prefixes     = ["10.0.1.0/24"]
}
resource "azurerm_network_interface" "nic" {
  name                = "nic_tf"
  location            = "West Europe"
  resource_group_name = var.rg

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = var.rsa_bite
}
resource "azurerm_linux_virtual_machine" "tf_vm" {
  name                  = var.vm_name
  location              = azurerm_resource_group.rs.location
  resource_group_name   = var.rg
  network_interface_ids = [azurerm_network_interface.nic.id]
  size                  = var.vm_size
  #lifecycle {
  # prevent_destroy=true
  #}
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  os_disk {
    name                 = "tf_vm_disque"
    storage_account_type = "Premium_LRS"
    caching              = "ReadWrite"
  }
  computer_name  = "devmachine"
  admin_username = "houssem"
  admin_ssh_key {
    username   = "houssem"
    public_key = tls_private_key.ssh_key.public_key_openssh
  }
}
resource "azurerm_management_lock" "vm_lock_level" {
  name       = "vm-level"
  scope      = azurerm_linux_virtual_machine.tf_vm.id
  lock_level = "CanNotDelete"
  notes      = "Items can't be deleted in this subscription!"
}
resource "random_string" "resource_code" {
  length  = 5
  special = false
  upper   = false
}


resource "azurerm_storage_account" "tfstate" {
  name                            = "tfstate${random_string.resource_code.result}"
  resource_group_name             = azurerm_resource_group.rs.name
  location                        = azurerm_resource_group.rs.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = true

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}
