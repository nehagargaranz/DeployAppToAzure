# Creating log analytics workspace which would store monitoring data.
resource "azurerm_log_analytics_workspace" "logs_analytics" {
  count = var.kubernetes.enable_log_analytics ? 1 : 0

  name                = local.common_resource_name
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  sku                 = var.kubernetes.log_analytics_workspace_sku
  tags                = var.tags
}

# Below would create ContainerInsights resource.
resource "azurerm_log_analytics_solution" "logs_analytics" {
  count = var.kubernetes.enable_log_analytics ? 1 : 0

  solution_name         = "ContainerInsights"
  location              = azurerm_resource_group.resource_group.location
  resource_group_name   = azurerm_resource_group.resource_group.name
  workspace_resource_id = azurerm_log_analytics_workspace.logs_analytics[0].id
  workspace_name        = azurerm_log_analytics_workspace.logs_analytics[0].name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}
