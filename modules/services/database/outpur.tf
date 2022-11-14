output "db_endpoint" {
  value = aws_db_instance.application_db.endpoint
}
output "db_address" {
  value = aws_db_instance.application_db.address
}
