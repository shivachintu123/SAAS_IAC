resource "random_password" "password" {
  length  = 16
  special = false
}
terraform {
  backend "s3" {
    bucket = "terraformstateovaledgetest1"
    key    = "ovaledge4"
    region = "us-east-1"

  }
}


resource "aws_db_instance" "default" {
  identifier                = var.db_identifier
  allocated_storage         = var.db_allocated_storage
  engine                    = var.engine
  engine_version            = var.engine_version
  instance_class            = var.db_class
  db_name                   = var.db_name
  username                  = var.db_username
  #"${jsondecode(aws_secretsmanager_secret_version.password.secret_string["username"])}"
  #var.db_username
  port                      = var.db_port
  password                  = "${random_password.password.result}"
  #random_password.password.result
  parameter_group_name      = "default.mysql5.7"
  skip_final_snapshot       = true
  deletion_protection       = false

  publicly_accessible       = false

  db_subnet_group_name      = "${aws_db_subnet_group.default.name}"
  #var.db_subnetgroupname
  #var.db_subnetgroupname
  backup_retention_period   = var.db_backup_retention_period
  final_snapshot_identifier = var.db_final_snapshot_identifier

  monitoring_interval       = true
  
  #storage_encrypted = true
}