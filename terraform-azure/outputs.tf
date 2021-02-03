output "es_image_id" {
  value = data.azurerm_image.elasticsearch.name
}

output "kibana_image_id" {
  value = data.azurerm_image.kibana.name
}

output "vm_password" {
  value = var.use_ssh_key ? null : random_string.vm-login-password[0].result
}

output "resource_group_name" {
  value = azurerm_resource_group.elasticsearch.name
}

output "vnet_name" {
  value = azurerm_virtual_network.elasticsearch_vnet[0].name
}

output "vnet_id" {
  value = azurerm_virtual_network.elasticsearch_vnet[0].id
}
