resource "azurerm_virtual_network" "vnet" {
  name                = local.vnet_name
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  address_space       = [var.network.vnet_address_space]
  tags                = var.tags
}

# AKS cluster would be placed in this subnet
resource "azurerm_subnet" "k8s_subnet" {
  name                 = "k8s-subnet"
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.network.node_address_space]
  service_endpoints    = ["Microsoft.KeyVault", "Microsoft.Sql"]
}

# Gets the network security group created by AKS to be able to associate it with above subnet.
data "azurerm_resources" "k8s_nsg" {
  resource_group_name = data.azurerm_resource_group.node_resource_group.name
  type                = "Microsoft.Network/networkSecurityGroups"
  depends_on = [
    azurerm_kubernetes_cluster.k8s
  ]
}

resource "azurerm_subnet_network_security_group_association" "k8s_nsg_subnet" {
  subnet_id                 = azurerm_subnet.k8s_subnet.id
  network_security_group_id = data.azurerm_resources.k8s_nsg.resources.0.id
}