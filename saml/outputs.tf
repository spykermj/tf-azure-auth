output "cert" {
  value = "-----BEGIN CERTIFICATE-----\n${azuread_service_principal_token_signing_certificate.this.value}\n-----END CERTIFICATE-----\n"
}

output "issuer" {
  value = local.issuer
}
