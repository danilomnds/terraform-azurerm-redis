locals {
  default_tags = {
    deployedby  = "Terraform"
    provider    = "azr"
    region      = replace(lower(var.location), " ", "")
    create_date = formatdate("DD/MM/YY hh:mm", timeadd(timestamp(), "-3h"))
    type        = "saas"
    resource    = "database"
  }
  tags = merge(local.default_tags, var.tags)
}