resource "azurerm_network_interface" "web_vnic" {
  name                      = "${var.project_name}_web_${count.index}"
  location                  = "${var.azure_region}"
  resource_group_name       = "${var.resource_group}"
  network_security_group_id = "${azurerm_network_security_group.nsg_web.id}"
  count                     = "${var.web_count}"

  ip_configuration {
    name = "${var.project_name}_web_${count.index}"

    subnet_id                     = "${element(azurerm_subnet.subnet.*.id, count.index)}"
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_virtual_machine" "web" {
  name                          = "${var.project_name}_web_${count.index}"
  location                      = "${var.azure_region}"
  resource_group_name           = "${var.resource_group}"
  network_interface_ids         = ["${element(azurerm_network_interface.web_vnic.*.id, count.index)}"]
  vm_size                       = "${var.web_instance_size}"
  delete_os_disk_on_termination = "true"
  count                         = "${var.web_count}"

  storage_os_disk {
    name              = "${var.project_name}_web_${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04.0-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "${var.project_name}-web-${count.index}"
    admin_username = "${var.admin_username}"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.admin_username}/.ssh/authorized_keys"
      key_data = "${file("keys/${var.project_name}.pub")}"
    }
  }
}

resource "azurerm_virtual_machine_extension" "apache" {
  depends_on           = ["azurerm_virtual_machine.web"]
  name                 = "apache"
  location             = "${var.azure_region}"
  resource_group_name  = "${var.resource_group}"
  virtual_machine_name = "${var.project_name}_web_${count.index}"
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"
  count                = "${var.web_count}"

  settings = <<SETTINGS
    {
        "commandToExecute": "sudo bash -c 'apt-get update && apt-get -y install apache2 && echo ${var.project_name}_web_${count.index} > /var/www/html/index.html'"
    }
    SETTINGS
}

locals {
  web_addresses = "${azurerm_network_interface.web_vnic.*.private_ip_address}"
}

output "addresses" {
  value = "${local.web_addresses}"
}
