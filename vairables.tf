
variable "location" {
  description = "Azure Region"
  type        = string
  default     = "westeurope"
}

variable "mysql_admin_login" {
  description = "MySQL Admin Benutzername"
  type        = string
  default     = "mysqladmin"
}

variable "mysql_admin_password" {
  description = "MySQL Admin Passwort"
  type        = string
  sensitive   = true
}

variable "mysql_database_name" {
  description = "Name der MySQL Datenbank"
  type        = string
  default     = "appdb"
}

variable "ghcr_image" {
  description = "GHCR Image (z.B. ghcr.io/org/javascript-app:latest)"
  type        = string
}

variable "ghcr_username" {
  description = "GHCR Benutzername (GitHub-Username)"
  type        = string
}

variable "ghcr_password" {
  description = "GitHub PAT mit read:packages für GHCR"
  type        = string
  sensitive   = true
}

variable "container_cpu" {
  description = "CPU für Azure Container Instance"
  type        = number
  default     = 1
}

variable "container_memory" {
  description = "RAM (GB) für Azure Container Instance"
  type        = number
  default     = 2
}
