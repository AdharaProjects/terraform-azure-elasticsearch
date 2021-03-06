resource "random_string" "vm-login-password" {
  count = var.use_ssh_key ? 0 : 1

  length = 16
  special = true
  override_special = "!@#%&-_"
}

resource "azurerm_resource_group" "elasticsearch" {
  location = var.location
  name = "rg-es-${var.resource_group_name}"
}

resource "azurerm_virtual_network" "elasticsearch_vnet" {
  count = var.create_network ? 1 : 0

  name                = "vnet-es-${var.es_cluster}"
  location            = var.location
  resource_group_name = azurerm_resource_group.elasticsearch.name
  address_space       = [ "10.1.0.0/24" ]
}

resource "azurerm_subnet" "elasticsearch_subnet" {
  count = var.create_network ? 1 : 0

  name                 = "snet-es-${var.es_cluster}"
  resource_group_name  = azurerm_resource_group.elasticsearch.name
  virtual_network_name = azurerm_virtual_network.elasticsearch_vnet[0].name
  address_prefixes     = [ "10.1.0.0/24" ]
}
