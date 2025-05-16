# Fetch the secret metadata
data "aws_secretsmanager_secret" "db_creds" {
  name = "my-db-creds"
}

# Fetch the latest secret value
data "aws_secretsmanager_secret_version" "db_creds" {
  secret_id = data.aws_secretsmanager_secret.db_creds.id
}
