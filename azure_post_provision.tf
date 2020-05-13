data "azurerm_public_ip" "controller" {
  depends_on          = [azurerm_virtual_machine.controller]
  name                = azurerm_public_ip.controller_public_ip.name
  resource_group_name = var.resource_group
}

output "public_ip_address" {
  value = data.azurerm_public_ip.controller.ip_address
}

resource "null_resource" "call_ansible" {
  depends_on = [azurerm_virtual_machine.controller]

  provisioner "local-exec" {
    command = "ansible-playbook --ask-vault-pass ${var.ansible_playbook_path} -e cloud=azure -e {'${jsonencode("address")}: ${jsonencode(local.web_addresses)}'} -e avi_controller=${data.azurerm_public_ip.controller.ip_address} -e azure_rg_name=${var.resource_group} -e avi_password=${var.admin_password} -e azure_vnet=${azurerm_virtual_network.vnet.name} -e azure_se_subnet=${azurerm_subnet.subnet[0].name}"
  }
}

