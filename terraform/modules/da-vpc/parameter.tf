#Keycloak
data "aws_ssm_parameter" "web_db_name" {
  name = "/dev/WEBAPP_DB_NAME"
}
data "aws_ssm_parameter" "web_db_user" {
  name = "/dev/WEBAPP_DB_USER"
}
data "aws_ssm_parameter" "web_db_host" {
  name = "/dev/WEBAPP_DB_HOST"
}
data "aws_ssm_parameter" "web_debug" {
  name = "/dev/WEBAPP_DEBUG"
}
data "aws_ssm_parameter" "web_db_password" {
  name = "/dev/WEBAPP_DB_PASSWORD"
}

data "aws_ssm_parameter" "secret_key" {
  name = "/dev/SECRET_KEY"
}
data "aws_ssm_parameter" "keycloak_base_uri" {
  name = "/dev/KEYCLOACK_BASE_URI"
}
data "aws_ssm_parameter" "keycloak_realm_name" {
  name = "/dev/KEYCLOACK_REALM_NAME"
}
data "aws_ssm_parameter" "oidc_rp_client_id" {
  name = "/dev/OIDC_RP_CLIENT_ID"
}
data "aws_ssm_parameter" "oidc_rp_client_secret_webapp" {
  name = "/dev/OIDC_RP_CLIENT_SECRET_WEBAPP"
}
data "aws_ssm_parameter" "keycloak_db_name" {
  name = "/dev/KEYCLOACK_DB_NAME"
}
data "aws_ssm_parameter" "keycloak_db_user" {
  name = "/dev/KEYCLOACK_DB_USER"
}
data "aws_ssm_parameter" "keycloak_db_password" {
  name = "/dev/KEYCLOACK_DB_PASSWORD"
}
data "aws_ssm_parameter" "keycloak_admin" {
  name = "/dev/KEYCLOAK_ADMIN"
}
data "aws_ssm_parameter" "keycloak_admin_password" {
  name = "/dev/KEYCLOAK_ADMIN_PASSWORD"
}

#Webapp
data "aws_ssm_parameter" "aes_generated_secret" {
  name = "/dev/AES_GENERATED_SECRET"
}
data "aws_ssm_parameter" "hmac_generated_secret" {
  name = "/dev/HMAC_GENERATED_SECRET"
}
data "aws_ssm_parameter" "rsa_generated_private_key" {
  name = "/dev/RSA_GENERATED_PRIVATE_KEY"
}
data "aws_ssm_parameter" "rsa_enc_generated_private_key" {
  name = "/dev/RSA_ENC_GENERATED_PRIVATE_KEY"
}
data "aws_ssm_parameter" "kc_db_url_host" {
  name = "/dev/KC_DB_URL_HOST"
}
data "aws_ssm_parameter" "kc_db_url_database" {
  name = "/dev/KC_DB_URL_DATABASE"
}
data "aws_ssm_parameter" "kc_db_username" {
  name = "/dev/KC_DB_USERNAME"
}
data "aws_ssm_parameter" "kc_db_password" {
  name = "/dev/KC_DB_PASSWORD"
}
data "aws_ssm_parameter" "kc_hostname" {
  name = "/dev/KC_HOSTNAME"
}
data "aws_ssm_parameter" "oidc_rp_client_secret" {
  name = "/dev/OIDC_RP_CLIENT_SECRET"
}
data "aws_ssm_parameter" "keycloak_realm_name_id" {
  name = "/dev/KEYCLOACK_REALM_NAME"
}
data "aws_ssm_parameter" "keycloak_hostname" {
  name = "/dev/KC_HOSTNAME"
}
data "aws_ssm_parameter" "keycloak_client_id" {
  name = "/dev/KEYCLOAK_CLIENT_ID"
}
