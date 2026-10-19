# =============================================================================
# Random password para PostgreSQL
# =============================================================================
resource "random_password" "postgres_admin" {
  length           = 20
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# =============================================================================
# Private DNS Zone - PostgreSQL
# =============================================================================
resource "azurerm_private_dns_zone" "postgres" {
  name                = "${var.prefix}-${var.environment}.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgres" {
  name                  = "link-postgres-vnet"
  private_dns_zone_name = azurerm_private_dns_zone.postgres.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  resource_group_name   = azurerm_resource_group.rg.name
  registration_enabled  = false
  tags                  = var.tags
}

# =============================================================================
# PostgreSQL Flexible Server (Private Access)
# =============================================================================
resource "azurerm_postgresql_flexible_server" "postgres" {
  name                          = "psql-${var.prefix}-${var.environment}"
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  version                       = var.postgres_version
  delegated_subnet_id           = azurerm_subnet.snet_db.id
  private_dns_zone_id           = azurerm_private_dns_zone.postgres.id
  public_network_access_enabled = false

  administrator_login    = "psqladmin"
  administrator_password = random_password.postgres_admin.result

  sku_name   = var.postgres_sku
  storage_mb = var.postgres_storage_mb
  zone       = "1"

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false

  tags = var.tags

  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.postgres
  ]

  lifecycle {
    ignore_changes = [zone]
  }
}

resource "azurerm_postgresql_flexible_server_database" "appdb" {
  name      = "appdb"
  server_id = azurerm_postgresql_flexible_server.postgres.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

# =============================================================================
# Private DNS Zone - Blob Storage
# =============================================================================
resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "blob" {
  name                  = "link-blob-vnet"
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  resource_group_name   = azurerm_resource_group.rg.name
  registration_enabled  = false
  tags                  = var.tags
}

# =============================================================================
# Storage Account (sin acceso público)
# =============================================================================
resource "azurerm_storage_account" "storage" {
  name                     = "st${var.prefix}${var.environment}${random_string.storage_suffix.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  public_network_access_enabled   = false
  allow_nested_items_to_be_public = false
  min_tls_version                 = "TLS1_2"

  blob_properties {
    versioning_enabled = false
  }

  tags = var.tags
}

resource "random_string" "storage_suffix" {
  length  = 6
  special = false
  upper   = false
}

# =============================================================================
# Private Endpoint - Storage Blob
# =============================================================================
resource "azurerm_private_endpoint" "pe_blob" {
  name                = "pe-blob-${var.prefix}-${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.snet_endpoints.id
  tags                = var.tags

  private_service_connection {
    name                           = "psc-blob"
    private_connection_resource_id = azurerm_storage_account.storage.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.blob.id]
  }
}