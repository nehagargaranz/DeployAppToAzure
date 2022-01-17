resource "kubernetes_namespace" "app_ns" {
  depends_on = [
    azurerm_kubernetes_cluster.k8s
  ]
  metadata {
    annotations = {
      name = "azure-golang"
    }
    name = "azure-golang"
  }
}

# It would provide environment configuration for the pods
resource "kubernetes_config_map" "db_config" {
  depends_on = [module.main_postgres_server]
  metadata {
    name      = "golang-database-config"
    namespace = kubernetes_namespace.app_ns.metadata.0.name
  }
  data = {
    VTT_DBNAME = "golangDb"
    VTT_DBPORT = 5432
    VTT_DBHOST = module.main_postgres_server.pgsql_fqdn
  }
}