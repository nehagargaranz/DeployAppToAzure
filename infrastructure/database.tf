resource "azurerm_resource_group" "postgres_resource_group" {
  name     = var.postgres.server_resource_group_name
  location = var.postgres.server_location
}

locals {
  has_pgsql_failover_hub = var.pgsql_failover_info != null
}

# Generate random string to be used for postgresql server Password
resource "random_password" "admin_password" {
  length  = 32
  special = true
}

# This is the main PostgreSQL server
module "main_postgres_server" {
  source                       = "./postgresql_server"
  pgsql_server_name            = var.postgres.server_name
  region                       = azurerm_resource_group.postgres_resource_group.location
  resource_group_name          = azurerm_resource_group.postgres_resource_group.name
  create_mode                  = "Default"
  administrator_login          = var.postgres.administrator_login
  administrator_login_password = random_password.admin_password.result
  tags                         = var.tags
  postgres_sku_name            = var.postgres.sku_name
  whitelist_subnet_id          = azurerm_subnet.k8s_subnet.id
}

# This is the failover replica server
module "replica_postgres_server" {
  source                    = "./postgresql_server"
  count                     = local.has_pgsql_failover_hub ? 1 : 0
  depends_on                = [module.main_postgres_server]
  pgsql_server_name         = var.pgsql_failover_info.server_name
  region                    = var.pgsql_failover_info.region
  resource_group_name       = azurerm_resource_group.postgres_resource_group.name
  create_mode               = "Replica"
  creation_source_server_id = module.main_postgres_server.pgsql_server_id
  tags                      = var.tags
  postgres_sku_name         = var.postgres.sku_name
  whitelist_subnet_id       = azurerm_subnet.k8s_subnet.id
}

# Adding main pgsql server login username as a secret to Key Vault 
resource "azurerm_key_vault_secret" "pgsql_server_admin_username" {
  name         = "pgsql-username"
  value        = "${var.postgres.administrator_login}@${module.main_postgres_server.pgsql_server_name}"
  key_vault_id = azurerm_key_vault.key_vault.id
  depends_on   = [azurerm_role_assignment.key_vault_admin]
}

# Adding main pgsql server login password as a secret to Key Vault 
resource "azurerm_key_vault_secret" "pgsql_server_admin_password" {
  name         = "pgsql-password"
  value        = random_password.admin_password.result
  key_vault_id = azurerm_key_vault.key_vault.id
  depends_on   = [azurerm_role_assignment.key_vault_admin]
}