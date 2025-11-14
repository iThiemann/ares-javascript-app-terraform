
############################
# Lokale Variablen
############################

locals {
  project_name = "aresjavascriptapp"
}

############################
# Random Suffix für globale Namen
############################

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  numeric = true
  special = false
}

############################
# Resource Group
############################

resource "azurerm_resource_group" "rg" {
  name     = "${local.project_name}-rg"
  location = var.location
}

############################
# Azure Container Registry
############################

resource "azurerm_container_registry" "acr" {
  # ACR-Namen dürfen nur Kleinbuchstaben und Zahlen enthalten, min. 5, max. 50 Zeichen
  name                = "${local.project_name}acr${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = false

  tags = {
    project = local.project_name
  }
}

############################
# Azure Database for MySQL Flexible Server 8.4.0
############################

resource "azurerm_mysql_flexible_server" "mysql" {
  name                = "${local.project_name}-mysql-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  administrator_login    = var.mysql_admin_login
  administrator_password = var.mysql_admin_password

  # Explizit MySQL 8.4.0 – check azurerm-Provider
  version  = "8.0.21"
  sku_name = "GP_Standard_D2ds_v4"

  backup_retention_days = 7

  storage {
    size_gb = 20
  }

  tags = {
    project = local.project_name
  }
}

resource "azurerm_mysql_flexible_database" "db" {
  name                = var.mysql_database_name
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_mysql_flexible_server.mysql.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"
}

# Firewall-Regel: "Allow access to Azure services"
resource "azurerm_mysql_flexible_server_firewall_rule" "allow_azure_services" {
  name                = "allow-azure-services"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_mysql_flexible_server.mysql.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

############################
# Azure Container Instance (ACI) mit GHCR-Image
############################

resource "azurerm_container_group" "aci" {
  name                = "${local.project_name}-aci"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  os_type         = "Linux"
  ip_address_type = "Public"

  # Öffentlicher DNS-Name: aresjavascriptapp-xxxxx.westeurope.azurecontainer.io
  dns_name_label = "${local.project_name}-${random_string.suffix.result}"

  container {
    name   = local.project_name
    image  = var.ghcr_image
    cpu    = var.container_cpu
    memory = var.container_memory

    ports {
      port     = 3000
      protocol = "TCP"
    }

    # Env-Vars für DB-Connect – in deiner App z.B. über process.env.MYSQL_HOST etc.
    environment_variables = {
      DB_HOST     = azurerm_mysql_flexible_server.mysql.fqdn
      DB_PORT     = "3306"
      DB_DATABASE = azurerm_mysql_flexible_database.db.name
      DB_USERNAME = "${var.mysql_admin_login}@${azurerm_mysql_flexible_server.mysql.name}"
      DB_PASSWORD = var.mysql_admin_password
    }
  }

  # Login für GitHub Container Registry
  image_registry_credential {
    server   = "ghcr.io"
    username = var.ghcr_username
    password = var.ghcr_password
  }

  tags = {
    project = local.project_name
  }

  depends_on = [
    azurerm_mysql_flexible_server.mysql,
    azurerm_mysql_flexible_database.db,
    azurerm_mysql_flexible_server_firewall_rule.allow_azure_services,
    azurerm_container_registry.acr
  ]
}
