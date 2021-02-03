data "template_file" "data_userdata_es_script" {
  template = "${file("${path.module}/../templates/user_data.elasticsearch.sh")}"

  vars = {
    volume_name             = ""
    elasticsearch_data_dir  = var.elasticsearch_data_dir
    elasticsearch_logs_dir  = var.elasticsearch_logs_dir
    heap_size               = var.data_heap_size
    es_cluster              = var.es_cluster
    es_environment          = "${var.environment}-${var.es_cluster}"
    security_groups         = ""
    availability_zones      = ""
    minimum_master_nodes    = format("%d", floor(var.masters_count / 2 + 1))
    master                  = "false"
    data                    = "true"
    bootstrap_node          = "false"
    http_enabled            = "true"
    security_enabled        = var.security_enabled
    monitoring_enabled      = var.monitoring_enabled
    xpack_monitoring_host   = var.xpack_monitoring_host
    license_type            = var.xpack_license_type
    masters_count           = var.masters_count
    datas_count             = var.datas_count
  }
}

resource "azurerm_linux_virtual_machine_scale_set" "data-nodes" {
  count = var.datas_count == 0 ? 0 : 1

  name = "vmss-es-${var.es_cluster}-data-nodes"
  resource_group_name = azurerm_resource_group.elasticsearch.name
  location = var.location

  source_image_id = data.azurerm_image.elasticsearch.id
  sku = var.data_instance_type
  instances = var.datas_count
  
  computer_name_prefix = "${var.es_cluster}-data"
  admin_username = "ubuntu"
  admin_password = var.use_ssh_key ? null : random_string.vm-login-password[0].result
  disable_password_authentication = var.use_ssh_key ? true : false
  custom_data = base64encode(data.template_file.data_userdata_es_script.rendered)

  dynamic "admin_ssh_key" {
    for_each = var.use_ssh_key ? [1] : []
    content {
      username   = "ubuntu"
      public_key = var.ssh_key
    }
  }

  network_interface {
    name = "nic-es-${var.es_cluster}-data-nodes"
    primary = true

    ip_configuration {
      name = "ipconf-es-${var.es_cluster}-data-nodes"
      primary = true
      subnet_id = var.create_network ? azurerm_subnet.elasticsearch_subnet[0].id : var.subnet_id
    }
  }

  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  data_disk {
    caching              = "ReadWrite"
    create_option        = "Empty"
    disk_size_gb         = var.elasticsearch_volume_size
    lun                  = 0
    storage_account_type = "Standard_LRS"
  }
}
