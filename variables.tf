variable "db_name" {
  type        = string
  description = "rds mysql name to identify"
  default     = "ovaledgerds"
}

variable "db_identifier" {
  type        = string
  description = "rds mysql name to identify "
  default     = "ovaledgerdsterraformlatest"
}
variable "engine" {
  type        = string
  description = "specify mysql or aurora-mysql"
  default     = "mysql"
}
variable "db_class" {
  type        = string
  description = "RDS hardware configurations"
  default     = "db.t2.micro"
}
variable "db_subnetgroupname" {
  type        = string
  description = "db subnet group name belongs to"
  default     = "ovaledgerds"
}
variable "db_username" {
  type        = string
  description = "database root username"
  default     = "admin"
}

variable "db_port" {
  type        = number
  description = "port to open"
  default     = 3306
}
variable "db_region" {
  type        = string
  description = "region to deploy rds"
  default     = "us-east-2"
}
variable "engine_version" {
  type        = string
  description = "specify a engine version 5.7.34 if it is mysql aurora 5.7.mysql_aurora.2.03.2"
  default     = "5.7"
}
variable "db_allocated_storage" {
  type        = number
  description = "minimum storage"
  default     = 20
}

variable "db_backup_retention_period" {
  type        = number
  description = "backup for how many days"
  default     = 14
}

variable "oe_secret_managername" {
  type        = string
  description = "Secret manager name to create"
  default     = "testsecretmanager"
}

variable "db_final_snapshot_identifier" {
  type = string
  description = "wgile destroying final snapshot identifier"
  default = "ovaledgerds"
}

