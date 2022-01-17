# The identity pods would use to access key vault secrets.
resource "azurerm_user_assigned_identity" "pod_identity" {
  name                = "${local.common_resource_name}-${var.kv_pod_identity}"
  resource_group_name = data.azurerm_resource_group.node_resource_group.name
  location            = data.azurerm_resource_group.node_resource_group.location
}

# Providing permissions to the pod identity to be able to access key vault secrets.
resource "azurerm_role_assignment" "key_vault_secrets" {
  scope                = azurerm_key_vault.key_vault.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.pod_identity.principal_id
}
