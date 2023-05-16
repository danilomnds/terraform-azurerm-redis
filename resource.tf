resource "azurerm_redis_cache" "redis" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  capacity            = var.capacity
  family              = var.family
  sku_name            = var.sku_name
  enable_non_ssl_port = var.enable_non_ssl_port
  dynamic "identity" {
    for_each = var.identity != null ? [var.identity] : []
    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
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
      day_of_week                                       = redis_configuration.value.day_of_week
      aof_backup_enabled                                = lookup(redis_configuration.value, "aof_backup_enabled", false)
      aof_backup_enabledaof_storage_connection_string_0 = lookup(redis_configuration.value, "aof_backup_enabledaof_storage_connection_string_0", null)
      aof_backup_enabledaof_storage_connection_string_1 = lookup(redis_configuration.value, "aof_backup_enabledaof_storage_connection_string_1", null)
      enable_authentication                             = lookup(redis_configuration.value, "enable_authentication ", true)
      maxmemory_reserved                                = lookup(redis_configuration.value, "maxmemory_reserved", null)
      maxmemory_delta                                   = lookup(redis_configuration.value, "maxmemory_delta", null)
      maxmemory_policy                                  = lookup(redis_configuration.value, "maxmemory_policy", "volatile-lru")
      maxfragmentationmemory_reserved                   = lookup(redis_configuration.value, "maxfragmentationmemory_reserved", null)
      rdb_backup_enabled                                = lookup(redis_configuration.value, "rdb_backup_enabled", false)
      rdb_backup_frequency                              = lookup(redis_configuration.value, "rdb_backup_frequency ", null)
      rdb_backup_max_snapshot_count                     = lookup(redis_configuration.value, "rdb_backup_max_snapshot_count", null)
      rdb_storage_connection_string                     = lookup(redis_configuration.value, "rdb_storage_connection_string", null)
    }
  }
  tags = local.tags
  lifecycle {
    ignore_changes = [
      tags["create_date"]
    ]
  }
}

resource "azurerm_redis_firewall_rule" "redis_firewall" {
  for_each            = var.firewall_rules != null ? { for k, v in var.firewall_rules : k => v if v != null } : {}
  name                = lookup(each.value, "name", null) == null ? each.key : lookup(each.value, "name", null)
  redis_cache_name    = azurerm_redis_cache.redis.name
  resource_group_name = var.resource_group_name
  start_ip            = lookup(each.value, "start_ip", null)
  end_ip              = lookup(each.value, "end_ip", null)
}

resource "azurerm_role_assignment" "redis_contributor" {
  for_each             = var.azure_ad_groups != [] ? toset(var.azure_ad_groups) : []
  scope                = azurerm_redis_cache.redis.id
  role_definition_name = "Redis Cache Contributor"
  principal_id         = each.value
}