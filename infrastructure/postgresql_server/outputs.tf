output "pgsql_server_id" {
  value = azurerm_postgresql_server.pgsql_server.id
}

output "pgsql_fqdn" {
  value = azurerm_postgresql_server.pgsql_server.fqdn
}

output "pgsql_server_name" {
  value = azurerm_postgresql_server.pgsql_server.name
}
