locals {
  secrets_path = replace(data.aws_secretsmanager_secret.registry_token.arn, "/registry_.*/", "*")
  db_credentials = jsondecode(data.aws_secretsmanager_secret_version.db_credentials.secret_string)
}


# Ref - https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html
resource "aws_iam_role" "task_execution_role" {
  name = "${var.prefix}-task-execution-role-${var.environment}"


  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "ecs-tasks.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "task_execution_policy" {
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams",
        "ssm:GetParameters",
        "kms:Decrypt"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "${aws_cloudwatch_log_group.microblog.arn}"
    },    
    {
      "Effect": "Allow",
      "Action": "secretsmanager:GetSecretValue",
      "Resource": "*"
    }
  ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "task_execution_policy_attach" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = aws_iam_policy.task_execution_policy.arn
}


resource "aws_iam_role" "task_role" {
  name = "${var.prefix}-task-role-${var.environment}"


  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "ecs-tasks.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_ecs_cluster" "this" {
  name = "${var.prefix}-${var.environment}"

  setting {
    name  = "containerInsights"
    value = var.containerinsights
  }
}

resource "aws_security_group" "microblog" {
  name        = "${var.prefix}-microblog-${var.environment}"
  description = "Fargate microblog"
  vpc_id      = var.vpc

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
}

resource "aws_security_group" "microblog-allow" {
  name        = "${var.prefix}-microblog-${var.environment}-allow"
  description = "Fargate microblog"
  vpc_id      = var.vpc

  egress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow mysql access from microblog container"
  }

  egress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow tcp access from microblog container"
  }
}

resource "aws_ecs_service" "microblog" {
  name                  = "${var.prefix}-${var.environment}"
  cluster               = aws_ecs_cluster.this.id
  task_definition       = aws_ecs_task_definition.microblog.arn
  desired_count         = var.desired_count
  launch_type           = "FARGATE"
  platform_version      = "1.4.0" // required for mounting efs
  wait_for_steady_state = true
  force_new_deployment  = var.force_new_deployment

  network_configuration {
    security_groups  = [aws_security_group.alb.id, aws_security_group.db.id, aws_security_group.microblog-allow.id]
    subnets          = var.private_subnet
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = module.alb.target_group_arns[0]
    container_name   = "microblog"
    container_port   = 5000
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
  depends_on = [aws_rds_cluster_instance.cluster_instances]
}

resource "aws_ecs_task_definition" "microblog" {
  family                   = "${var.prefix}-${var.environment}"
  execution_role_arn       = aws_iam_role.task_execution_role.arn
  task_role_arn            = aws_iam_role.task_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  container_definitions    = <<CONTAINER_DEFINITION
[
  {
      "environment": [
                {
                    "name": "SECRET_KEY",
                    "value": "my-secret-key"
                },
                {
                    "name": "DATABASE_URL",
                    "value": "mysql+pymysql://${local.db_credentials["username"]}:${local.db_credentials["password"]}@${aws_rds_cluster.this.endpoint}/microblog"
                }
            ],
      "essential": true,
      "name": "microblog",
      "image": "${var.docker_image}",
      "repositoryCredentials": {
          "credentialsParameter": "${data.aws_secretsmanager_secret_version.registry_docker_hub_secret.arn}"
      },
      "cpu": 0,
      "mountPoints": [],
      "volumesFrom": [],
      "portMappings": [
          {
              "hostPort": 5000,
              "containerPort": 5000,
              "protocol": "tcp"
          }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.microblog.name}",
          "awslogs-region": "${var.aws_region}",
          "awslogs-stream-prefix": "microblog"
        }
      }
  }
  
]
CONTAINER_DEFINITION
  depends_on               = [aws_rds_cluster_instance.cluster_instances]
}


resource "aws_cloudwatch_log_group" "microblog" {
  name              = "/${var.prefix}/${var.environment}/fg-task"
  retention_in_days = var.log_retention_in_days
}

