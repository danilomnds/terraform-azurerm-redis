# Module - Azure Cache for Redis
[![COE](https://img.shields.io/badge/Created%20By-CCoE-blue)]()
[![HCL](https://img.shields.io/badge/language-HCL-blueviolet)](https://www.terraform.io/)
[![Azure](https://img.shields.io/badge/provider-Azure-blue)](https://registry.terraform.io/providers/hashicorp/azurerm/latest)

Module developed to standardize the Azure Cache for Redis creation.

## Compatibility Matrix

| Module Version | Terraform Version | AzureRM Version |
|----------------|-------------------| --------------- |
| v1.0.0         | v1.5.0            | 3.61.0          |
| v2.0.0         | v1.9.8            | 4.9.0           |

## Specifying a version

To avoid that your code get updates automatically, is mandatory to set the version using the `source` option. 
By defining the `?ref=***` in the the URL, you can define the version of the module.

Note: The `?ref=***` refers a tag on the git module repo.

## Important note

This module grantees the role "Redis Cache Contributor Custom" for the azure AD groups listed using the var azure_ad_groups.
In case of adding/removal of a privilege it can be made here [https://dev.azure.com/timbrasil/Projeto_IaC/_git/azr-rbac?path=/environments/shared/customroles/redis_cache_contributor_custom.tf](https://dev.azure.com/timbrasil/Projeto_IaC/_git/azr-rbac?path=/environments/shared/customroles/redis_cache_contributor_custom.tf)

## Use case

```hcl
module "<redis-cache-name>" {
  source = "git::https://github.com/danilomnds/terraform-azurerm-redis?ref=v2.0.0"
  name = "<redis-cache-name>"
  location = "<your-region>"
  resource_group_name = "<resource-group>"
  capacity = <1>
  family = "<C>"
  sku_name = "Basic"
  zones = []
  redis_configuration = {
    maxmemory_reserved = <10>
    maxmemory_delta    = <2>
    maxmemory_policy   = "allkeys-lru"
  }
  # subnet_id works only for premium tier. For basic and standard you can use private endpoints
  subnet_id = <subnet_id>
  azure_ad_groups = ["group id 1","group id 2"]
  firewall_rules = [    
    { name = "rulename1""
       start_ip = "1.2.3.4"
       end_ip = "2.3.4.5"
    },
    {
      name = "rulename1""
       start_ip = "1.2.3.6"
       end_ip = "2.3.4.7"
    }
  ]
  tags = {
    key1 = "value1"
    key2 = "value2"    
  }  
}
output "redis_name" {
  value = module.<redis-cache-name>.name
}
output "redis_id" {
  value = module.<redis-cache-name>.id
}
```

## Use case Clustering + HA

```hcl
module "<redis-cache-name>" {
  source = "git::https://github.com/danilomnds/terraform-azurerm-redis?ref=v2.0.0"
  name = "<redis-cache-name>"
  location = "<your-region>"
  resource_group_name = "<resource-group>"
  capacity = <1>
  family = "<P>"
  sku_name = "Premium"
  zones = [1,2]
  # two nodes. Ex: P1 with 2 shards, totalizes 12GiB of capacity.
  shard_count = 2
  redis_configuration = {
    maxmemory_reserved = <10>
    maxmemory_delta    = <2>
    maxmemory_policy   = "allkeys-lru"
  }
  # subnet_id works only for premium tier. For basic and standard you can use private endpoints
  subnet_id = <subnet_id>
  azure_ad_groups = ["group id 1","group id 2"]
  firewall_rules = [    
    { name = "rulename1""
       start_ip = "1.2.3.4"
       end_ip = "2.3.4.5"
    },
    {
      name = "rulename1""
       start_ip = "1.2.3.6"
       end_ip = "2.3.4.7"
    }
  ]
  tags = {
    key1 = "value1"
    key2 = "value2"    
  }  
}
output "redis_name" {
  value = module.<redis-cache-name>.name
}
output "redis_id" {
  value = module.<redis-cache-name>.id
}
```

## Input variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | redis cache name | `string` | n/a | `Yes` |
| location | azure region | `string` | n/a | `Yes` |
| resource_group_name | resource group name where the resource(s) will be created | `string` | n/a | `Yes` |
| capacity | the size of the Redis cache to deploy | `number` | n/a | `Yes` |
| family | the sku family/pricing group to use | `string` | `C` | `Yes` |
| sku_name | the sku of redis to use | `string` | `Basic` | `Yes` |
| non_ssl_port_enabled | enable the non-ssl port (6379) - disabled by default | `bool` | `false` | No |
| identity | optional block as defined below | `object()` | n/a | No |
| minimum_tls_version | the minimum TLS version | `string` | `1.2` | No |
| patch_schedule | optional block as defined below | `object()` | n/a | No |
| private_static_ip_address | the static ip address to assign to the redis cache when hosted inside the virtual network. this argument implies the use of subnet_id | `string` | n/a | No |
| public_network_access_enabled  | whether or not public network access is allowed for this redis cache | `bool` | `false` | No |
| redis_configuration | a redis_configuration as defined below - with some limitations by sku - defaults/details are shown below| `object()` | n/a | No |
| replicas_per_master | amount of replicas to create per master for this redis cache | `number` | `1` | No |
| replicas_per_primary | amount of replicas to create per primary for this redis cache | `number` | `1` | No |
| redis_version | redis version | `number` | `6` | No |
| tenant_settings | a mapping of tenant settings to assign to the resource | `map(string)` | `{}` | No |
| shard_count | only available when using the premium sku the number of shards to create on the redis cluster | `number` | n/a | No |
| subnet_id | only available when using the premium sku the id of the subnet within which the redis cache should be deployed | `string` | n/a | No |
| tags | tags for the resource | `map(string)` | `{}` | No |
| zones | specifies a list of availability zones in which this redis cache should be located | `list` | `[]]` | No |
| azure_ad_groups | list of azure AD groups that will be granted the Application Insights Component Contributor role  | `list` | `[]` | No |
| firewall_rules | map with one or more firewall rules for the cache for redis  | `map(map(string))` | `{}` | No |

# Objects. List of acceptable parameters
| Variable Name (Block) | Parameter | Description | Type | Default | Required |
|-----------------------|-----------|-------------|------|---------|:--------:|
| identity | type | pecifies the type of Managed Service Identity that should be configured | `string` | `null` | No |
| identity | identity_ids | Specifies a list of User Assigned Managed Identity IDs to be assigned to resource | `liststring()` | `null` | No |
| patch_schedule | day_of_week | weekday name | `string` | `null` | No |
| patch_schedule | start_hour_utc | the Start Hour for maintenance in UTC | `number` | `null` | No |
| patch_schedule | maintenance_window | the iso 8601 timespan which specifies the amount of time the redis cache can be updated | `string` | `null` | No |
| redis_configuration | aof_backup_enabled | enable or disable aof persistence for this redis cache | `bool` | `false` | No |
| redis_configuration | aof_storage_connection_string_0 | first storage account connection string for aof persistence | `string` | `null` | No |
| redis_configuration | aof_storage_connection_string_1 | second storage account connection string for aof persistence | `string` | `null` | No |
| redis_configuration | authentication_enabled | If set to false, the Redis instance will be accessible without authentication | `bool` | `true` | No |
| redis_configuration | active_directory_authentication_enabled | Enable Microsoft Entra (AAD) authentication | `bool` | `false` | No |
| redis_configuration | maxmemory_reserved | value in megabytes reserved for non-cache usage e.g. failover | `number` | `null` | No |
| redis_configuration | maxmemory_delta | the max-memory delta for this redis instance | `number` | `null` | No |
| redis_configuration | maxmemory_policy | how redis will select what to remove when maxmemory is reached | `string` | `null` | No |
| redis_configuration | data_persistence_authentication_method | Preferred auth method to communicate to storage account used for data persistence | `string` | `null` | No |
| redis_configuration | maxfragmentationmemory_reserved | value in megabytes reserved to accommodate for memory fragmentation | `number` | `null` | No |
| redis_configuration | rdb_backup_enabled | is backup enabled | `bool` | `null` | No |
| redis_configuration | rdb_backup_frequency  | The backup frequency in minutes. Only supported on premium skus | `number` | `null` | No |
| redis_configuration | rdb_backup_max_snapshot_count | the maximum number of snapshots to create as a backup | `number` | `null` | No |
| redis_configuration | rdb_storage_connection_string | the connection string to the storage account | `string` | `null` | No |
| redis_configuration | storage_account_subscription_id | The ID of the Subscription containing the Storage Account | `string` | `null` | No |
| redis_configuration | notify_keyspace_events |  Keyspace notifications allows clients to subscribe to Pub/Sub channels in order to receive events affecting the Redis data set in some way | `string` | `null` | No |

## Output variables

| Name | Description |
|------|-------------|
| name | redis cache name |
| id | redis cache id |

## Documentation

Terraform Azure Cache for Redis: <br>
[https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/redis_cache](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/redis_cache)<br>

Terraform Azure Cache Firewall Rule: <br>
[https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/redis_firewall_rule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/redis_firewall_rule)<br>