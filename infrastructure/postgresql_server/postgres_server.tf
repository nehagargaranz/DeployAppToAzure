# This module creates a single postgres server and configures its network access

resource "azurerm_postgresql_server" "pgsql_server" {
 
  name                = var.pgsql_server_name
  location            = var.region
  resource_group_name = var.resource_group_name
  create_mode               = var.create_mode
  creation_source_server_id = var.creation_source_server_id
  administrator_login          = var.administrator_login
  administrator_login_password = var.administrator_login_password
  tags                         = var.tags
  sku_name                     = var.postgres_sku_name
  backup_retention_days        = 7
  geo_redundant_backup_enabled = true
  auto_grow_enabled            = true
  version                         = 11
  ssl_enforcement_enabled         = false
}

# Allowing AKS cluster subnet to access database
resource "azurerm_postgresql_virtual_network_rule" "pgsql_vnet_rule" {
  name                = "postgresql-vnet-rule"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_postgresql_server.pgsql_server.name
  subnet_id           = var.whitelist_subnet_id
}
