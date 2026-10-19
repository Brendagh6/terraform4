output "resource_group_name" {
  description = "Nombre del Resource Group"
  value       = azurerm_resource_group.rg.name
}

output "vnet_id" {
  description = "ID de la Virtual Network"
  value       = azurerm_virtual_network.vnet.id
}

output "web_app_name" {
  description = "Nombre del App Service"
  value       = azurerm_linux_web_app.webapp.name
}

output "web_app_default_hostname" {
  description = "Hostname por defecto del App Service"
  value       = azurerm_linux_web_app.webapp.default_hostname
}

output "web_app_principal_id" {
  description = "Principal ID (Managed Identity) del Web App"
  value       = azurerm_linux_web_app.webapp.identity[0].principal_id
}

output "postgres_fqdn" {
  description = "FQDN privado de PostgreSQL"
  value       = azurerm_postgresql_flexible_server.postgres.fqdn
}

output "postgres_admin_login" {
  description = "Usuario administrador de PostgreSQL"
  value       = azurerm_postgresql_flexible_server.postgres.administrator_login
}

output "postgres_admin_password" {
  description = "Contraseña de administrador de PostgreSQL"
  value       = random_password.postgres_admin.result
  sensitive   = true
}

output "storage_account_name" {
  description = "Nombre del Storage Account"
  value       = azurerm_storage_account.storage.name
}

output "vm_private_ip" {
  description = "IP privada de la VM worker"
  value       = azurerm_network_interface.nic_vm.private_ip_address
}

output "vm_admin_username" {
  description = "Usuario administrador de la VM"
  value       = var.admin_username
}

output "vm_admin_password" {
  description = "Contraseña de la VM (usar con Bastion)"
  value       = random_password.vm_admin.result
  sensitive   = true
}

output "bastion_host_name" {
  description = "Nombre del Azure Bastion"
  value       = azurerm_bastion_host.bastion.name
}