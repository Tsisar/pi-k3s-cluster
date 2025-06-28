resource "random_password" "postgres_password" {
  length  = 16
  special = false
}

resource "vault_generic_secret" "postgres" {
  path = "secret/postgres"

  data_json = jsonencode({
    user     = var.postgres_username,
    password = random_password.postgres_password.result
  })
}