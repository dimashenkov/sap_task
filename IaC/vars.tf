variable "tags" {
  description = "AWS Tags to add to all resources created (where possible); see https://aws.amazon.com/answers/account-management/aws-tagging-strategies/"
  type        = map(any)
  default     = {
    Name        = "microblog"
    Owner       = "DevOPs"
    Service     = "microblog"
    Environment = "PRD"
  }
}

variable "aws_region" {
  description = "aws region"
  default     = "eu-west-1"
}

variable "prefix" {
  description = "Prefix for all the resources to be created. Please note thst 2 allows only lowercase alphanumeric characters and hyphen"
  default     = "microblog"
}

variable "desired_count" {
  description = "The number of instances of fargate tasks to keep running"
  default     = "1"
}
variable "log_retention_in_days" {
  description = "The number of days to retain cloudwatch log"
  default     = "7"
}

variable "environment" {
  description = "Name of the application environment. e.g. dev,uat,prd"
  default     = "prd"
}

variable "db_backup_retention_days" {
  description = "Number of days to retain db backups"
  default     = "7"
}

variable "db_backup_window" {
  description = "The daily time range during which automated backups for rds are created if automated backups are enabled using the BackupRetentionPeriod parameter. Time in UTC."
  default     = "07:00-09:00"
}

variable "db_max_capacity" {
  description = "The maximum Aurora capacity unit of the db. Ref - https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless.how-it-works.html"
  default     = "1"
}
variable "db_min_capacity" {
  description = "The minimum Aurora capacity unit of the db. Ref - https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless.how-it-works.html"
  default     = "1"
}
variable "db_engine_version" {
  description = "The database engine version"
  default     = "8.0.mysql_aurora.3.04.0"
}
variable "db_auto_pause" {
  description = "Whether to enable auto pause"
  default     = true
}

variable "db_seconds_until_auto_pause" {
  description = "The time in seconds before Aurora DB is paused"
  default     = 300
}
variable "task_memory" {
  description = "The amount (in MiB) of memory used by the task"
  default     = 512
}
variable "task_cpu" {
  description = "The number of cpu units used by the task"
  default     = 256
}

variable "vpc" {
  description = "vpc"
  default     = "vpc-081127f235b38e129"
}

variable "public_subnet" {
  description = "list of subnets to use for ALB"
  default     = ["subnet-0cbad66394501bebb", "subnet-0badd23d2ec609ce9"]
}

variable "private_subnet" {
  description = "list of subnets to use for containers"
  default     = ["subnet-0cbad66394501bebb", "subnet-0badd23d2ec609ce9"]
}

variable "db_azs" {
  description = "list of AZs to use for DB"
  default     = ["eu-west-1a", "eu-west-1b"]
}

variable "db_subnets" {
  description = "list of subnets to use for db"
  default     = ["subnet-0cbad66394501bebb", "subnet-0badd23d2ec609ce9"]
}

variable "internal_alb" {
  default     = false
  description = "type of ALB to use"
}

variable "docker_image" {
  default = "sektasoldier/microblog:latest"
}

variable "custom_cert_arn" {
  default = null
}

variable "containerinsights" {
  default = "disabled"
}

variable "force_new_deployment" {
  default     = false
  description = "Force new deployment of the task definition"
}

variable "task_cpu_high_threshold" {
  description = "The CPU value above which downscaling kicks in"
  default     = "75"
}

variable "task_cpu_low_threshold" {
  description = "The CPU value below which downscaling kicks in"
  default     = "30"
}

variable "scaling_up_cooldown" {
  description = "The amount of time, in seconds, after a scaling activity completes and before the next scaling activity can start (upscaling)"
  default     = "60"
}

variable "scaling_down_cooldown" {
  description = "The amount of time, in seconds, after a scaling activity completes and before the next scaling activity can start (downscaling)"
  default     = "300"
}

variable "scaling_up_adjustment" {
  description = " The number of tasks by which to scale, when the upscaling parameters are breached"
  default     = "1"
}

variable "scaling_down_adjustment" {
  description = " The number of tasks by which to scale (negative for downscaling), when the downscaling parameters are breached"
  default     = "-1"
}

variable "max_task" {
  description = "Maximum number of tasks should the service scale to"
  default     = "2"
}

variable "min_task" {
  description = "Minimum number of tasks should the service always maintain"
  default     = "1"
}
