# Terraform4

Despliega la infraestructura de Azure definida en este directorio. Antes de
empezar, instala Terraform (>= 1.5) y Azure CLI, e inicia sesión en la
suscripción que usará Terraform:

```powershell
az login
az account set --subscription "<ID-o-nombre-de-tu-suscripcion>"
```

Ejecuta los siguientes comandos desde el directorio que contiene la carpeta
`Terraform4`:

```powershell
cd Terraform4
terraform init
terraform fmt -recursive
terraform validate
terraform plan -out tfplan
terraform apply tfplan

# Ver contraseñas (son valores sensibles; no las compartas)
terraform output -raw vm_admin_password
terraform output -raw postgres_admin_password

# Al terminar, elimina los recursos para evitar cargos
terraform destroy
```

`terraform.tfvars` contiene los valores por defecto para la región, tamaños y
redes. La salida de `terraform plan` debe revisarse antes de aplicar. El estado
de Terraform y el archivo `tfplan` pueden contener información sensible; no
los publiques ni los subas al control de versiones.