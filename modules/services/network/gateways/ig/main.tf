resource "aws_internet_gateway" "tomcat_ig" {
  vpc_id = var.vpc_id
  tags = {
    Name = var.ig_name
  }
}
resource "aws_route_table" "tomcat_rtig" {
  vpc_id = var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tomcat_ig.id
  }
  tags = {
    Name = var.ig_rt_name
  }
}
resource "aws_route_table_association" "tomcat_rt_association" {
  count = length(var.subnet_id)
  route_table_id = aws_route_table.tomcat_rtig.id
  subnet_id = element(var.subnet_id, count.index)
}