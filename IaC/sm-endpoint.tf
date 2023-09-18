resource "aws_vpc_endpoint" "secrets_manager" {
  vpc_id            = var.vpc  # Replace with your VPC ID
  service_name      = "com.amazonaws.${var.aws_region}.secretsmanager"  # Replace with your region
  vpc_endpoint_type = "Interface"

  subnet_ids = var.public_subnet  # Replace with your subnet IDs

  security_group_ids = [aws_security_group.secrets_manager_sg.id]

  private_dns_enabled = true
}

resource "aws_security_group" "secrets_manager_sg" {
  vpc_id = var.vpc  # Replace with your VPC ID

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["172.31.0.0/20", "172.31.32.0/20"]  # Replace with your CIDR blocks
  }
}
