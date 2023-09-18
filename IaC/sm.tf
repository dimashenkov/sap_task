# # locals {
# #   smcreds = {
# #     username = "mansiongroup"
# #     password = data.vault_generic_secret.repository_credentials.data["registry_read_token"]
# #   }
# # }

# resource "random_string" "secret_path" {
#   length  = 16
#   special = false
# }

# resource "aws_secretsmanager_secret" "registry_token" {
#   name = "/rundeck/${random_string.secret_path.result}/registry_token"
#   tags = var.tags
# }

# resource "aws_secretsmanager_secret_version" "registry_secret" {
#   secret_id     = aws_secretsmanager_secret.registry_token.arn
#   secret_string = jsonencode(local.smcreds)
# }

# resource "aws_secretsmanager_secret" "storage_password" {
#   name = "/rundeck/${random_string.secret_path.result}/storage_password"
#   tags = var.tags
# }

# resource "aws_secretsmanager_secret_version" "storage_password_secret" {
#   secret_id     = aws_secretsmanager_secret.storage_password.arn
#   secret_string = data.vault_generic_secret.secrets.data["${var.prefix}.storage_password"]
# }

# resource "aws_secretsmanager_secret" "config_password" {
#   name = "/rundeck/${random_string.secret_path.result}/config_password"
#   tags = var.tags
# }

# resource "aws_secretsmanager_secret_version" "config_password_secret" {
#   secret_id     = aws_secretsmanager_secret.config_password.arn
#   secret_string = data.vault_generic_secret.secrets.data["${var.prefix}.config_password"]
# }
