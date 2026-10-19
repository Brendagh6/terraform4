# =============================================================================
# App Service Plan (Linux - B1)
# =============================================================================
resource "azurerm_service_plan" "asp" {
  name                = "asp-${var.prefix}-${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = var.app_service_sku
  tags                = var.tags
}

# =============================================================================
# Linux Web App + Managed Identity + VNet Integration
# =============================================================================
resource "azurerm_linux_web_app" "webapp" {
  name                = "app-${var.prefix}-web-${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.asp.id
  https_only          = true

  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on              = false
    minimum_tls_version    = "1.2"
    vnet_route_all_enabled = true

    application_stack {
      node_version = "20-lts"
    }
  }

  tags = var.tags
}

# VNet Integration
resource "azurerm_app_service_virtual_network_swift_connection" "vnet_integration" {
  app_service_id = azurerm_linux_web_app.webapp.id
  subnet_id      = azurerm_subnet.snet_app.id
}

# =============================================================================
# Random password para la VM
# =============================================================================
resource "random_password" "vm_admin" {
  length           = 16
  special          = true
  override_special = "!@#$%&*()-_=+[]{}"
}

# =============================================================================
# NIC para la VM
# =============================================================================
resource "azurerm_network_interface" "nic_vm" {
  name                = "nic-vm-worker"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.snet_vm.id
    private_ip_address_allocation = "Dynamic"
  }
}

# =============================================================================
# Linux VM Worker (B2ats_v2)
# =============================================================================
resource "azurerm_linux_virtual_machine" "vm_worker" {
  name                = "vm-worker"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  size                = var.vm_size
  admin_username      = var.admin_username

  network_interface_ids = [
    azurerm_network_interface.nic_vm.id
  ]

  admin_password                  = random_password.vm_admin.result
  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  tags = var.tags
}

# =============================================================================
# RBAC - Managed Identity del Web App → Storage Blob Data Contributor
# =============================================================================
resource "azurerm_role_assignment" "webapp_storage" {
  scope                = azurerm_storage_account.storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_linux_web_app.webapp.identity[0].principal_id
}

# =============================================================================
# RBAC - Reader sobre el Resource Group
# =============================================================================
resource "azurerm_role_assignment" "webapp_rg_reader" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Reader"
  principal_id         = azurerm_linux_web_app.webapp.identity[0].principal_id
}