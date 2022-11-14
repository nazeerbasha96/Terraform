resource "aws_security_group" "lbr_sg" {
  vpc_id = var.vpc_id
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 80
    to_port = 80
    protocol = "tcp"
    description = "application load balancer security group"
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    to_port = 0
    protocol = -1
  }
  tags = {
    Name = var.lbr_sg_name
  }
}
resource "aws_lb" "application_lbr" {
  name = var.lbr_name
  load_balancer_type = "application"
  internal = false
  subnets = var.subnet_id
  security_groups = [aws_security_group.lbr_sg.id]
}
resource "aws_lb_target_group" "lbr_tg" {
    health_check {
      interval = 30
      path = "/fithealth2/healthcheck"
      protocol = "HTTP"
      timeout = 3
      healthy_threshold = 5
      unhealthy_threshold = 2
    }
    name = var.tg_name
    port = 8080
    protocol = "HTTP"
    vpc_id = var.vpc_id
  
}
resource "aws_alb_listener" "lbr_listener" {
  load_balancer_arn = aws_lb.application_lbr.arn
  protocol = "HTTP"
  port = 80
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.lbr_tg.arn
  }
}
resource "aws_lb_target_group_attachment" "lbr_tg_attachment1" {
    target_group_arn = aws_lb_target_group.lbr_tg.arn
    target_id = var.instance1
    port = 8080
}
resource "aws_lb_target_group_attachment" "lbr_tg_attachment2" {
    target_group_arn = aws_lb_target_group.lbr_tg.arn
    target_id = var.instance2
    port = 8080
}