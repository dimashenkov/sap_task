resource "aws_security_group" "alb" {
  name        = "${var.prefix}-alb-${var.environment}"
  description = "Allow HTTPS inbound traffc"
  vpc_id      = var.vpc

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 08
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

}


module "alb" {
  source             = "terraform-aws-modules/alb/aws"
  version            = "~> 5.0"
  name               = "${var.prefix}-${var.environment}"
  load_balancer_type = "application"
  internal           = var.internal_alb
  vpc_id             = var.vpc
  subnets            = var.public_subnet
  security_groups    = [aws_security_group.alb.id]
  idle_timeout       = 600
  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]
  target_groups = [
    {
      name             = "${var.prefix}-lb-${var.environment}"
      backend_protocol = "HTTP"
      target_type      = "ip"
      backend_port     = 5000
      health_check = {
        path                = "/health"
        interval            = 60
        unhealthy_threshold = 5
      }
    }
  ]
}
