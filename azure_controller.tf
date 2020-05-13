resource "azurerm_network_interface" "controller_vnic" {
  name                = "${var.project_name}_controller"
  location            = var.azure_region
  resource_group_name = var.resource_group

  ip_configuration {
    name = "${var.project_name}_controller"

    subnet_id                     = element(azurerm_subnet.subnet.*.id, 1)
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.controller_public_ip.id
  }
}

resource "azurerm_network_interface_security_group_association" "controller_nsg" {
  network_interface_id      = azurerm_network_interface.controller_vnic.id
  network_security_group_id = azurerm_network_security_group.nsg_controller.id
}

data "template_file" "userdata" {
  template = file("files/userdata.json")

  vars = {
    password = var.admin_password
  }
}

resource "azurerm_virtual_machine" "controller" {
  name                             = "${var.project_name}_controller"
  location                         = var.azure_region
  resource_group_name              = var.resource_group
  network_interface_ids            = [azurerm_network_interface.controller_vnic.id]
  vm_size                          = var.controller_instance_size
  delete_os_disk_on_termination    = "true"
  delete_data_disks_on_termination = "true"

  storage_image_reference {
    publisher = "avi-networks"
    offer     = "avi-vantage-adc"
    sku       = "avi-vantage-adc-1802"
    version   = var.controller_version
  }

  plan {
    name      = "avi-vantage-adc-1802"
    publisher = "avi-networks"
    product   = "avi-vantage-adc"
  }

  storage_os_disk {
    name              = "${var.project_name}_controller"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  os_profile {
    computer_name  = "${var.project_name}-controller"
    admin_username = var.avi_username
    admin_password = var.admin_password
    custom_data    = data.template_file.userdata.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = false

    ssh_keys {
      path     = "/home/${var.avi_username}/.ssh/authorized_keys"
      key_data = file("keys/${var.project_name}.pub")
    }
  }
}

