data "template_file" "client_userdata_kibana_script" {
  template = "${file("${path.module}/../templates/user_data.kibana.sh")}"

  vars = {
    security_enabled        = var.security_enabled
    monitoring_enabled      = var.monitoring_enabled
    datas_count             = var.datas_count
  }
}

resource "azurerm_linux_virtual_machine_scale_set" "client-nodes" {
  count = var.clients_count == 0 ? 0 : 1

  name = "vmss-es-${var.es_cluster}-client-nodes"
  resource_group_name = azurerm_resource_group.elasticsearch.name
  location = var.location

  source_image_id = data.azurerm_image.kibana.id
  sku = var.client_instance_type
  instances = var.clients_count

  computer_name_prefix = "${var.es_cluster}-client"
  admin_username = "ubuntu"
  admin_password = var.use_ssh_key ? null : random_string.vm-login-password[0].result
  disable_password_authentication = var.use_ssh_key ? true : false
  custom_data = base64encode(data.template_file.client_userdata_kibana_script.rendered)

  dynamic "admin_ssh_key" {
    for_each = var.use_ssh_key ? [1] : []
    content {
      username   = "ubuntu"
      public_key = var.ssh_key
    }
  }

  network_interface {
    name = "nic-es-${var.es_cluster}-client-nodes"
    primary = true

    ip_configuration {
      name = "ipconf-es-${var.es_cluster}-client-nodes"
      primary = true
      subnet_id = var.create_network ? azurerm_subnet.elasticsearch_subnet[0].id : var.subnet_id
    }
  }

  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}
