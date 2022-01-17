variable "subscription_id" {
  type = string
}

variable "tenant_id" {
  type = string
}

variable "location" {
  type = string
}

variable "aks_resource_prefix" {
  description = "Common resource prefix used for naming AKS resources"
  type        = string
}

variable "resource_prefix" {
  description = "Common resource prefix used for naming other Azure resources"
  type        = string
}

variable "kubernetes" {
  description = "Kubernetes configuration"
  type = object({
    authorized_ip_ranges : list(string)
    node_count : number
    vm_size : string
    version : string
    enable_auto_scaling : string
    min_count : number
    max_count : number
    vm_zones : list(number)
    max_pods : number
    enable_azure_policy : string
    enable_log_analytics : string
    log_analytics_workspace_sku : string
  })
}

variable "network" {
  description = "Network configuration"
  type = object({
    node_address_space : string
    vnet_address_space : string
    service_address_space : string
    cluster_dns_service_ip : string
    docker_bridge_address_space : string
  })
}

variable "postgres" {
  description = "Postgresql database server configuration"
  type = object({
    server_resource_group_name : string
    server_location : string
    server_name : string
    sku_name : string
    administrator_login : string
  })
}

variable "pgsql_failover_info" {
  description = "Information about the failover region, if null we wont create a read replica postgres server."
  type = object(
    {
      region : string
      server_name : string
    }
  )
  default = null
}

variable "keyvault" {
  description = "Postgresql database server configuration"
  type = object({
    authorized_ip_ranges : list(string)
  })
}

variable "kv_pod_identity" {
  description = "AAD Pod Identity which would be used by a pod to access key vault secrets"
  type        = string
}

variable "tags" {
  type = map(string)
}