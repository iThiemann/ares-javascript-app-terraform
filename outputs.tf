
output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "acr_name" {
  value = azurerm_container_registry.acr.name
}

output "mysql_fqdn" {
  value = azurerm_mysql_flexible_server.mysql.fqdn
}

output "mysql_database" {
  value = azurerm_mysql_flexible_database.db.name
}

output "aci_fqdn" {
  description = "FQDN der aresjavascriptapp Container Instanz"
  value       = azurerm_container_group.aci.fqdn
}

output "connection_string_example" {
  description = "Beispiel-Connection-String"
  value       = "mysql://${var.mysql_admin_login}@${azurerm_mysql_flexible_server.mysql.name}:${var.mysql_admin_password}@${azurerm_mysql_flexible_server.mysql.fqdn}:3306/${azurerm_mysql_flexible_database.db.name}"
  sensitive   = true
}
