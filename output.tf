output "password" {
  value = aws_db_instance.default.password
  sensitive = true
}
output "username" {
  value = aws_db_instance.default.username
}
output "rds_endpoint" {
  value = "${aws_db_instance.default.endpoint}"
}
