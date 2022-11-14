output "ec2_private_ip" {
  value = aws_instance.tomcat_ec2.private_ip
}
output "ec2_public_ip" {
  value = aws_instance.tomcat_ec2.public_ip
}
output "instance_id" {
  value = aws_instance.tomcat_ec2.id
}