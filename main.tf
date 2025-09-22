resource "azurerm_virtual_machine" "example_vm" {
  name                  = "example-vm"
  location              = azurerm_resource_group.example.location
  resource_group_name   = azurerm_resource_group.example.name
  network_interface_ids = [azurerm_network_interface.example.id]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "example_os_disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "hostname"
    admin_username = "adminuser"
    
    # 🔐 Hardcoded secret in custom_data (this will be detected by Aqua)
    custom_data = <<-EOF
      #!/bin/bash
      echo "MyAppPassword=HardcodedSecretAquaShouldCatch123#" >> /etc/environment
    EOF
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}
