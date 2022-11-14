output "instance_privateip" {
  value = module.tomcat_ec2[*].ec2_private_ip
}
output "instance_publicip"{
    value = module.jumpbox_ec2.ec2_public_ip
}
output "db_endpoint" {
  value = module.application_db.db_endpoint
}
output "db_address" {
  value = module.application_db.db_address
}
output "lbr_dns_name" {
  value = module.application_lbr.lbr_dns_name
}