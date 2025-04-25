# Security Group for Classic Load Balancer
resource "aws_security_group" "lb_sg" {
  name        = "classic-lb-sg"
  description = "Security group for Classic Load Balancer"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "classic-lb-sg"
  }
}

# Classic Load Balancer
resource "aws_elb" "web_lb" {
  name               = "web-classic-lb"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets           = data.aws_subnets.default.ids

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port          = 80
    lb_protocol      = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout            = 3
    target             = "HTTP:80/"
    interval           = 30
  }

  cross_zone_load_balancing   = true
  idle_timeout               = 60
  connection_draining        = true
  connection_draining_timeout = 300

  tags = {
    Name = "web-classic-lb"
  }

  instances = aws_instance.web_server[*].id
}