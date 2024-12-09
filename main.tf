resource "azurerm_redis_cache" "redis" {
  name                               = var.name
  location                           = var.location
  resource_group_name                = var.resource_group_name
  capacity                           = var.capacity
  family                             = var.family
  sku_name                           = var.sku_name
  access_keys_authentication_enabled = var.access_keys_authentication_enabled
  dynamic "identity" {
    for_each = var.identity != null ? [var.identity] : []
    content {
      type         = identity.value.type
      identity_ids = lookup(identity.value, "identity_ids", null)
    }
  }
  minimum_tls_version = var.minimum_tls_version
  dynamic "patch_schedule" {
    for_each = var.patch_schedule != null ? [var.patch_schedule] : []
    content {
      day_of_week        = patch_schedule.value.day_of_week
      start_hour_utc     = lookup(patch_schedule.value, "start_hour_utc", null)
      maintenance_window = lookup(patch_schedule.value, "maintenance_window", null)
    }
  }
  private_static_ip_address     = var.private_static_ip_address
  public_network_access_enabled = var.public_network_access_enabled
  dynamic "redis_configuration" {
    for_each = var.redis_configuration != null ? [var.redis_configuration] : []
    content {
      aof_backup_enabled                      = lookup(redis_configuration.value, "aof_backup_enabled", false)
      aof_storage_connection_string_0         = lookup(redis_configuration.value, "aof_storage_connection_string_0", null)
      aof_storage_connection_string_1         = lookup(redis_configuration.value, "aof_storage_connection_string_1", null)
      authentication_enabled                  = lookup(redis_configuration.value, "authentication_enabled ", true)
      active_directory_authentication_enabled = lookup(redis_configuration.value, "active_directory_authentication_enabled ", false)
      maxmemory_reserved                      = lookup(redis_configuration.value, "maxmemory_reserved", null)
      maxmemory_delta                         = lookup(redis_configuration.value, "maxmemory_delta", null)
      maxmemory_policy                        = lookup(redis_configuration.value, "maxmemory_policy", "volatile-lru")
      data_persistence_authentication_method  = lookup(redis_configuration.value, "data_persistence_authentication_method", null)
      maxfragmentationmemory_reserved         = lookup(redis_configuration.value, "maxfragmentationmemory_reserved", null)
      rdb_backup_enabled                      = lookup(redis_configuration.value, "rdb_backup_enabled", false)
      rdb_backup_frequency                    = lookup(redis_configuration.value, "rdb_backup_frequency ", null)
      rdb_backup_max_snapshot_count           = lookup(redis_configuration.value, "rdb_backup_max_snapshot_count", null)
      rdb_storage_connection_string           = lookup(redis_configuration.value, "rdb_storage_connection_string", null)
      storage_account_subscription_id         = lookup(redis_configuration.value, "storage_account_subscription_id", null)
      notify_keyspace_events                  = lookup(redis_configuration.value, "notify_keyspace_events", null)
    }
  }
  replicas_per_master  = var.replicas_per_master
  replicas_per_primary = var.replicas_per_primary
  redis_version        = var.redis_version
  tenant_settings      = var.tenant_settings
  shard_count          = var.shard_count
  subnet_id            = var.subnet_id
  tags                 = local.tags
  zones                = var.zones
  lifecycle {
    ignore_changes = [
      tags["create_date"]
    ]
  }
}

resource "azurerm_redis_firewall_rule" "redis_firewall" {
  depends_on = [azurerm_redis_cache.redis]
  for_each   = var.firewall_rules != null ? { for k, v in var.firewall_rules : k => v if v != null } : {}
  #for_each            = var.firewall_rules != null ? { for k, v in var.firewall_rules : k => v if v != null } : {}
  name                = each.value.name
  redis_cache_name    = azurerm_redis_cache.redis.name
  resource_group_name = var.resource_group_name
  start_ip            = each.value.start_ip
  end_ip              = each.value.end_ip
}

resource "azurerm_role_assignment" "redis_contributor" {
  for_each             = var.azure_ad_groups != [] ? toset(var.azure_ad_groups) : []
  scope                = azurerm_redis_cache.redis.id
  role_definition_name = "Redis Cache Contributor Custom"
  principal_id         = each.value
}