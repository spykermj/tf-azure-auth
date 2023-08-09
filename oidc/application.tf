data "azuread_client_config" "current" {}

resource "random_uuid" "ids" {
  count = length(var.app_roles)
}

resource "random_uuid" "permission_scope" {}

resource "azuread_application" "this" {
  display_name            = var.app_name
  owners                  = concat([data.azuread_client_config.current.object_id], var.extra_owners)
  sign_in_audience        = "AzureADMyOrg"
  prevent_duplicate_names = true

  logo_image = filebase64(var.logo)

  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph
    dynamic "resource_access" {
      for_each = var.graph_api_scopes
      content {
        id   = resource_access.value
        type = "Scope"
      }
    }
  }

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

  api {
    oauth2_permission_scope {
      admin_consent_description  = "Allow the application to access ${var.app_name} on behalf of the signed-in user."
      admin_consent_display_name = "Access"
      id                         = random_uuid.permission_scope.result
      type                       = "User"
      enabled                    = true
      value                      = "user"
    }
  }

  web {
    redirect_uris = [for path in var.redirect_paths : format("https://%s%s", var.hostname, path)]
    logout_url    = "https://${var.hostname}${var.logout_path}"

    implicit_grant {
      access_token_issuance_enabled = true
      id_token_issuance_enabled     = true
    }
  }

  feature_tags {
    gallery    = true
    enterprise = true
  }
}

resource "azuread_service_principal" "this" {
  application_id               = azuread_application.this.application_id
  owners                       = concat([data.azuread_client_config.current.object_id], var.extra_owners)
  app_role_assignment_required = true
}

resource "azuread_application_password" "this" {
  display_name          = "${var.app_name} secret"
  application_object_id = azuread_application.this.id
}
