resource "random_string" "snapshot_suffix" {
  length  = 8
  special = false
}

resource "aws_rds_cluster" "this" {
  cluster_identifier      = "${var.prefix}-${var.environment}-cluster"
  engine                  = "aurora-mysql"
  engine_mode             = "provisioned" # Change this line
  vpc_security_group_ids  = [aws_security_group.db.id]
  db_subnet_group_name    = aws_db_subnet_group.this.name
  engine_version          = var.db_engine_version
  availability_zones      = var.db_azs
  database_name           = local.db_credentials["username"]
  master_username         = local.db_credentials["password"]
  master_password         = "microblog"
  backup_retention_period = var.db_backup_retention_days
  preferred_backup_window = var.db_backup_window
  copy_tags_to_snapshot   = true
  skip_final_snapshot     = false

  # Remove the scaling_configuration block if not needed for provisioned mode

  final_snapshot_identifier = "${var.prefix}-${var.environment}-${random_string.snapshot_suffix.result}"
  lifecycle {
    ignore_changes = [availability_zones]
  }
  tags = var.tags  
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count                = 2 # To simulate an Aurora failover, you'd typically have more than one replica in your Aurora cluster, so that if the primary instance fails (or you manually trigger a failover), one of the replicas can be promoted to become the new primary instance.
  identifier           = "${var.prefix}-${var.environment}-instance-${count.index}"
  cluster_identifier   = aws_rds_cluster.this.id
  instance_class       = "db.r5.large" # Smallest instance type.
  engine               = "aurora-mysql"
  engine_version       = var.db_engine_version
  db_subnet_group_name = aws_db_subnet_group.this.name
  publicly_accessible  = false # Make it publicly accessible for debug
  tags = var.tags  
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.prefix}-${var.environment}"
  subnet_ids = var.db_subnets
  tags = var.tags  
}

resource "aws_security_group" "db" {
  vpc_id = var.vpc
  name   = "${var.prefix}-db-${var.environment}"
  ingress {
    protocol  = "tcp"
    from_port = 3306
    to_port   = 3306
    self      = true
  }
 ingress {
    protocol        = "tcp"
    from_port       = 3306
    to_port         = 3306
    security_groups = [aws_security_group.microblog.id]  # allowing access from microblog security group
  }
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
  tags = var.tags  
}

