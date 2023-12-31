data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_availability_zones" "this" {}

data "aws_secretsmanager_secret" "registry_token" {
  name = "registry_token" # replace with the name of the secret in Secrets Manager
}

data "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = "arn:aws:secretsmanager:eu-west-1:700466996490:secret:db_credentials-WShNB4" # replace with the secret ID or ARN
}

data "aws_secretsmanager_secret_version" "registry_docker_hub_credentials" {
  secret_id = "arn:aws:secretsmanager:eu-west-1:700466996490:secret:registry_docker_hub_credentials-mChu3P" # replace with the secret ID or ARN
}
