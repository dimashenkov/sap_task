data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_availability_zones" "this" {}

data "aws_secretsmanager_secret" "registry_token" {
  name = "registry_token" # replace with the name of the secret in Secrets Manager
}

data "aws_secretsmanager_secret_version" "db_password_secret" {
  secret_id = "arn:aws:secretsmanager:eu-west-1:700466996490:secret:db_password_secret-1dCu4X" # replace with the secret ID or ARN
}

data "aws_secretsmanager_secret_version" "registry_docker_hub_secret" {
  secret_id = "arn:aws:secretsmanager:eu-west-1:700466996490:secret:registry_docker_hub_secret-4tP2zO" # replace with the secret ID or ARN
}
