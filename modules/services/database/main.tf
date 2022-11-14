resource "aws_security_group" "application_db_sg" {
  vpc_id = var.vpc_id
  ingress {
    cidr_blocks = var.db_cidr
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    description = "db_security_group"
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = -1
  }
}
resource "aws_db_subnet_group" "db_subnet_group" {
  subnet_ids = var.subnet_id
  tags = {
    Name = var.db_subnet_group_name
  }
}
resource "aws_db_instance" "application_db" {
  allocated_storage      = var.allocated_storage
  db_name                = var.db_name
  engine                 = var.engine
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  username               = var.username
  password               = var.password
  parameter_group_name   = var.parameter_group_name
  skip_final_snapshot    = var.skip_final_snapshot
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.application_db_sg.id]
}
