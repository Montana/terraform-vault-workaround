terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "3.8.2"
    }
  }
}
# Delay the token creation
resource "time_sleep" "test" {
  create_duration = "5s"
}
# Get the token
data "external" "aws_vault_token" {
  depends_on = [time_sleep.test]
  program    = ["bash", "./vault-aws.sh", "arn:aws:iam::xxxxxxxx:role/xxxxxxxxx", "xxxxxxxxxxx"]
}
# Init the provider (VAULT_ADDR defined in env)
provider "vault" {
  token            = data.external.aws_vault_token.result.token
  skip_child_token = true
}
# Test by setting a secret
resource "vault_kv_secret" "secret" {
  path      = "mykvengine/data/mysecret"
  data_json = jsonencode({data = {
    test = "top",
    foo = "bar"
  }})
}
