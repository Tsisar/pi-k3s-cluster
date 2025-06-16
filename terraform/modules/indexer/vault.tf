resource "vault_generic_secret" "postgres" {
  path = "secret/postgres"

  data_json = jsonencode({
    user     = var.postgres_user,
    password = random_password.postgres_password.result
  })
}

resource "vault_generic_secret" "hasura" {
  path = "secret/hasura"

  data_json = jsonencode({
    user     = var.hasura_user,
    password = random_password.hasura_password.result
  })
}

data "vault_generic_secret" "rpc" {
    path = "secret/starknet_rpc"
}