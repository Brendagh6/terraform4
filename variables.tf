variable "location" {
  description = "Región de Azure"
  type        = string
  default     = "mexicocentral"
}

variable "prefix" {
  description = "Prefijo para nombres de recursos"
  type        = string
  default     = "tf4"
}

variable "environment" {
  description = "Ambiente (dev, test, prod)"
  type        = string
  default     = "dev"
}

variable "vnet_address_space" {
  description = "Address space de la VNet"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_app_prefix" {
  type    = list(string)
  default = ["10.0.1.0/24"]
}

variable "subnet_db_prefix" {
  type    = list(string)
  default = ["10.0.2.0/24"]
}

variable "subnet_vm_prefix" {
  type    = list(string)
  default = ["10.0.3.0/24"]
}

variable "subnet_endpoints_prefix" {
  type    = list(string)
  default = ["10.0.4.0/24"]
}

variable "subnet_bastion_prefix" {
  type    = list(string)
  default = ["10.0.5.0/26"] # Mínimo /26 requerido por Azure Bastion
}

variable "app_service_sku" {
  description = "SKU del App Service Plan"
  type        = string
  default     = "B1"
}

variable "vm_size" {
  description = "Tamaño de la VM worker"
  type        = string
  default     = "Standard_B2ats_v2"
}

variable "postgres_sku" {
  description = "SKU de PostgreSQL Flexible Server"
  type        = string
  default     = "B_Standard_B1ms"
}

variable "postgres_version" {
  type    = string
  default = "16"
}

variable "postgres_storage_mb" {
  type    = number
  default = 32768
}

variable "admin_username" {
  description = "Usuario administrador de la VM"
  type        = string
  default     = "azureuser"
}

variable "tags" {
  description = "Tags comunes"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "Terraform4"
    ManagedBy   = "Terraform"
    Owner       = "UTVT"
  }
}