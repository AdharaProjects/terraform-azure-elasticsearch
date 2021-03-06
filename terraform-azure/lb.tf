resource "azurerm_lb" "clients" {
  location = var.location
  name = "lbi-${var.es_cluster}-clients-lb"
  resource_group_name = azurerm_resource_group.elasticsearch.name

  frontend_ip_configuration {
    name = "es-${var.es_cluster}-ip"
    subnet_id = azurerm_subnet.elasticsearch_subnet[0].id
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_lb_backend_address_pool" "clients-lb-backend" {
  name = "lbbap-es-${var.es_cluster}-clients-lb"
  resource_group_name = azurerm_resource_group.elasticsearch.name
  loadbalancer_id = azurerm_lb.clients.id
}

resource "azurerm_lb_probe" "clients-httpprobe" {
  name = "lbp-${var.es_cluster}-clients-lb"
  port = 9200
  protocol = "Http"
  request_path = "/_cat/health"
  resource_group_name = azurerm_resource_group.elasticsearch.name
  loadbalancer_id = azurerm_lb.clients.id
}

// Elasticsearch access
resource "azurerm_lb_rule" "clients-lb-rule" {
  name = "lbr-es-${var.es_cluster}-clients-lb"
  backend_port = 9200
  frontend_port = 9200
  frontend_ip_configuration_name = "es-${var.es_cluster}-ip"
  backend_address_pool_id = azurerm_lb_backend_address_pool.clients-lb-backend.id
  protocol = "Tcp"
  loadbalancer_id = azurerm_lb.clients.id
  resource_group_name = azurerm_resource_group.elasticsearch.name
}
