variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "capacity" {
  type = number
}

variable "family" {
  type    = string
  default = "C"
}

variable "sku_name" {
  type    = string
  default = "Basic"
}

variable "access_keys_authentication_enabled" {
  type    = bool
  default = true
}

variable "non_ssl_port_enabled" {
  type    = bool
  default = false
}

variable "identity" {
  description = "Specifies the type of Managed Service Identity that should be configured on this resource"
  type = object({
    type         = string
    identity_ids = optional(list(string))
  })
  default = null
}

variable "minimum_tls_version" {
  type    = string
  default = "1.2"
}

variable "patch_schedule" {
  type = object({
    day_of_week        = string
    start_hour_utc     = optional(number)
    maintenance_window = optional(string)
  })
  default = null
}

variable "private_static_ip_address" {
  type    = string
  default = null
}

variable "public_network_access_enabled" {
  type    = bool
  default = false
}

variable "redis_configuration" {
  type = object({
    aof_backup_enabled                      = optional(bool)
    aof_storage_connection_string_0         = optional(string)
    aof_storage_connection_string_1         = optional(string)
    authentication_enabled                  = optional(bool)
    active_directory_authentication_enabled = optional(bool)
    maxmemory_reserved                      = optional(number)
    maxmemory_delta                         = optional(number)
    maxmemory_policy                        = optional(string)
    data_persistence_authentication_method  = optional(string)
    maxfragmentationmemory_reserved         = optional(number)
    rdb_backup_enabled                      = optional(bool)
    rdb_backup_frequency                    = optional(number)
    rdb_backup_max_snapshot_count           = optional(number)
    rdb_storage_connection_string           = optional(string)
    storage_account_subscription_id         = optional(string)
    notify_keyspace_events                  = optional(string)
  })
  default = null
}

variable "replicas_per_master" {
  type    = number
  default = 1
}

variable "replicas_per_primary" {
  type    = number
  default = 1
}

variable "redis_version" {
  type    = number
  default = 6
}

variable "tenant_settings" {
  type    = map(string)
  default = {}
}

variable "shard_count" {
  type    = number
  default = null
}

variable "subnet_id" {
  type    = string
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "zones" {
  type    = list(any)
  default = []
}

variable "firewall_rules" {
  type = list(object({
    name     = string
    start_ip = string
    end_ip   = string
  }))
  default = []
}

variable "azure_ad_groups" {
  type    = list(string)
  default = []
}