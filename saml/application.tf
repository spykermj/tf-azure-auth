data "azuread_client_config" "current" {}

resource "random_uuid" "ids" {
  count = length(var.app_roles)
}

locals {
  login_url = "https://${var.hostname}${var.login_path}"
  issuer = var.verified_domain ? local.login_url : "api://${data.azuread_client_config.current.tenant_id}/${var.app_name}"
}

resource "azuread_application" "this" {
  display_name = var.app_name
  owners       = [data.azuread_client_config.current.object_id]
  identifier_uris         = [local.issuer]
  sign_in_audience        = "AzureADMyOrg"
  prevent_duplicate_names = true

  logo_image = filebase64(var.logo)

  dynamic "app_role" {
    for_each = var.app_roles
    content {
      allowed_member_types = ["User"]
      description          = app_role.value.description
      display_name         = app_role.value.display_name
      value                = app_role.value.value
      id                   = random_uuid.ids[app_role.key].id
    }
  }

  web {
    redirect_uris = [for path in var.redirect_paths : format("https://%s%s", var.hostname, path)]
    logout_url    = "https://${var.hostname}${var.logout_path}"
  }

  feature_tags {
    enterprise            = true
    custom_single_sign_on = true
  }
}

resource "azuread_service_principal" "this" {
  application_id                = azuread_application.this.application_id
  preferred_single_sign_on_mode = "saml"
  login_url                     = local.login_url

  feature_tags {
    enterprise            = true
    gallery               = true
    custom_single_sign_on = true
  }
}

resource "azuread_service_principal_token_signing_certificate" "this" {
  service_principal_id = azuread_service_principal.this.id
}
