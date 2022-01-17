data "azurerm_client_config" "current" {
}

resource "azurerm_key_vault" "key_vault" {
  name                = "${var.resource_prefix}-vault"
  location            = data.azurerm_resource_group.node_resource_group.location
  resource_group_name = data.azurerm_resource_group.node_resource_group.name
  tenant_id           = var.tenant_id
  sku_name            = "standard"

  enable_rbac_authorization = "true"
  tags                      = var.tags

  # Not restricting network access below so that you won't have issue in creating and accessing secrets.
  # Ideally below should be in place to allow access to only authorized IPs or CIDRs.

  #   network_acls {
  #     bypass         = "AzureServices"
  #     default_action = "Deny"
  #     ip_rules       = var.keyvault.authorized_ip_ranges
  #     virtual_network_subnet_ids = [
  #       azurerm_subnet.k8s_subnet.id
  #     ]
  #   }
}

# Key Vault admin permissions to the current user 
resource "azurerm_role_assignment" "key_vault_admin" {
  scope                = azurerm_key_vault.key_vault.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}