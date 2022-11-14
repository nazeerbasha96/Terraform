resource "aws_security_group" "sg" {
  vpc_id = var.vpc_id
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 22
    to_port = 22
    protocol = "tcp"
    description = "SSH access for ec2_instance"
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
}
resource "aws_instance" "tomcat_ec2" {
  subnet_id = var.subnet_id
  ami = var.ami
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.sg.id]
  associate_public_ip_address = var.associate_public_ip_address
  key_name = var.key_name
  tags = {
    "Name" = var.instance_name
  }
}