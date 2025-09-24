terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_key_vault" "key_vault" {
  name                = var.key_vault
  location            = var.location
  resource_group_name = var.resource_group
  tenant_id           = var.tenant_id

  # "standard" or "premium"
  sku_name = var.sku_name

  # 7–90 days
  soft_delete_retention_days = var.soft_delete_retention_days

  purge_protection_enabled   = var.purge_protection_enabled
  enabled_for_disk_encryption = var.enabled_for_disk_encryption

  tags = var.tags

  network_acls {
    # "AzureServices" or "None" (can also be list like "AzureServices", "Batch", etc. in newer APIs)
    bypass      = "AzureServices"
    # "Allow" or "Deny"
    default_action = var.default_action

    # Optional allow-lists
    ip_rules                 = var.ip_rules
    virtual_network_subnet_ids = var.subnet_ids
  }

  timeouts {
    create = "15m"
    update = "15m"
    delete = "15m"
  }
}
