resource "aws_ecs_cluster" "microblog_cluster" {
  name = "microblog"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = "microblog-cluster"
    Environment = "production"
  }
}
