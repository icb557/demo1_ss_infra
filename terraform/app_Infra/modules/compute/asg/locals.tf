locals {
  db_host_parts = split(":", var.db_host)
  db_endpoint   = local.db_host_parts[0]
  db_port       = local.db_host_parts[1]
}