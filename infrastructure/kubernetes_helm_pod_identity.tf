resource "kubernetes_namespace" "aad_pod_identity" {
  depends_on = [
    azurerm_kubernetes_cluster.k8s
  ]
  metadata {
    name = "azure-identity"
    labels = {
      name = "azure-identity"
    }
  }
}

# request token from AAD, use that token to fetch secrets from key vault, and 
# get those secrets to the application to be able to connect to database server
resource "helm_release" "aad_pod_identity" {
  name       = "aad-pod-identity"
  repository = "https://raw.githubusercontent.com/Azure/aad-pod-identity/master/charts"
  chart      = "aad-pod-identity"
  version    = "3.0.3"
  namespace  = kubernetes_namespace.aad_pod_identity.metadata[0].name

  set {
    name  = "installCRDs"
    value = true
  }

  set {
    name  = "azureIdentities.${var.kv_pod_identity}.resourceID"
    value = azurerm_user_assigned_identity.pod_identity.id
  }

  set {
    name  = "azureIdentities.${var.kv_pod_identity}.clientID"
    value = azurerm_user_assigned_identity.pod_identity.client_id
  }

  set {
    name  = "azureIdentities.${var.kv_pod_identity}.type"
    value = "0"
  }

  set {
    name  = "azureIdentities.${var.kv_pod_identity}.binding.selector"
    value = var.kv_pod_identity
  }

  set {
    name  = "azureIdentities.${var.kv_pod_identity}.binding.name"
    value = var.kv_pod_identity
  }
}
