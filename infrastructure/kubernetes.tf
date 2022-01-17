resource "azurerm_kubernetes_cluster" "k8s" {
  name                = local.common_resource_name
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  node_resource_group = "${azurerm_resource_group.resource_group.name}-nodes"
  dns_prefix          = local.common_resource_name
  kubernetes_version  = var.kubernetes.version

  # Provide IPs to be able to restrict access to AKS service. Don't open it to all networks.
  # api_server_authorized_ip_ranges = var.kubernetes.authorized_ip_ranges

  default_node_pool {
    name                 = "default"
    node_count           = var.kubernetes.node_count
    vm_size              = var.kubernetes.vm_size
    vnet_subnet_id       = azurerm_subnet.k8s_subnet.id
    orchestrator_version = var.kubernetes.version
    enable_auto_scaling  = var.kubernetes.enable_auto_scaling
    min_count            = var.kubernetes.min_count
    max_count            = var.kubernetes.max_count
    # High availability can be ensured by keeping cluster nodes in different availability zones.
    availability_zones = var.kubernetes.vm_zones
    max_pods           = var.kubernetes.max_pods
  }

  # It would create a cluster with managed identities which could be used to 
  identity {
    type = "SystemAssigned"
  }


  network_profile {

    # network plugin could be azure or kubenet. Default is kubenet.
    # azure: pods are assigned private IPs from an Azure Virtual Network. Those IPs belong to the NICs of the VMs in scale set where those pods run.
    # kubenet: basic configuration. Pod IPs are cluster IPs, they do not belong to the Azure Virtual Network.
    network_plugin = "azure"

    # The Network Range used by the Kubernetes service
    service_cidr       = var.network.service_address_space
    dns_service_ip     = var.network.cluster_dns_service_ip
    docker_bridge_cidr = var.network.docker_bridge_address_space

    load_balancer_sku = "Standard"

  }

  tags = var.tags

  role_based_access_control {
    enabled = true
  }

  addon_profile {

    # Azure policy is enabled/disabled for AKS. It shows the compliance state of k8s resources
    azure_policy {
      enabled = var.kubernetes.enable_azure_policy
    }

    # Enable Azure Log Analytics add on to be able to monitor the cluster (metrices like health of cluster, CPU and memory usage on pods, etc.).
    oms_agent {
      enabled                    = var.kubernetes.enable_log_analytics
      log_analytics_workspace_id = var.kubernetes.enable_log_analytics ? azurerm_log_analytics_workspace.logs_analytics[0].id : null
    }
  }
}

data "azurerm_resource_group" "node_resource_group" {
  name = azurerm_kubernetes_cluster.k8s.node_resource_group
}

# Access to create load balancers in the Central subnet

resource "azurerm_role_assignment" "aks_control_vnet" {
  scope                = azurerm_virtual_network.vnet.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.k8s.identity[0].principal_id
}

# ---
# Access to contribute to the cluster nodes

resource "azurerm_role_assignment" "aks_control_vmss" {
  scope                = data.azurerm_resource_group.node_resource_group.id
  role_definition_name = "Virtual Machine Contributor"
  principal_id         = azurerm_kubernetes_cluster.k8s.kubelet_identity[0].object_id
}

# ---
# Access to read and assign user managed identity

resource "azurerm_role_assignment" "aks_control_identity" {
  scope                = data.azurerm_resource_group.node_resource_group.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = azurerm_kubernetes_cluster.k8s.kubelet_identity[0].object_id
}