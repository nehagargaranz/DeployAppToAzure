variable "administrator_login" {
  type        = string
  description = "Username for the admin, required if create_mode is \"Default\""
  default     = null
}

variable "administrator_login_password" {
  type        = string
  description = "Password for the admin, required if create_mode is \"Default\""
  sensitive   = true
  default     = null
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group this postgres server belongs to, should be the single resource group for the evo hub you are creating"
}

variable "region" {
  description = "Target Azure Region, see `az account list-locations -o table` for regions."
  type        = string
}

variable "pgsql_server_name" {
  description = "The name of this postgres server."
  type        = string
}

variable "tags" {
  description = "Map of tags to add to this resource"
  type        = map(string)
}

variable "create_mode" {
  description = "Which type of postgres server we are creating, either 'Default' for a stand alone server or 'Replica' for a read replica. If 'Replia' than creation_source_server_id needs to also be set"
  type        = string
  validation {
    condition     = contains(["Default", "Replica"], var.create_mode)
    error_message = "The create_mode variable must be one of either 'Default' or 'Replica'."
  }
}

variable "creation_source_server_id" {
  type        = string
  description = "Optional id of another postgres server. Only used if create_mode is 'Replica'"
  default     = null
}

variable "postgres_sku_name" {
  type        = string
  description = "The sku of the postgres server to create. If 'Replica' it will need to match the source server."
}

variable "whitelist_subnet_id" {
  type        = string
  description = "aks subnet id to be whitelisted."
}