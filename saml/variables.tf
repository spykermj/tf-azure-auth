variable "app_roles" {
  description = "A list of the app roles required for this application"
  type = list(object({
    description  = string
    display_name = string
    value        = string
  }))
}

variable "app_name" {
  description = "Name of this SAML application"
  type = string
}

variable "hostname" {
  description = "The host name of the application"
  type = string
}

variable "verified_domain" {
  # setting the identifier uri to a real host requires domain verification. Using an api:// uri gets around that
  # see https://github.com/MicrosoftDocs/azure-docs/blob/main/includes/active-directory-identifier-uri-patterns.md
  description = "If the hostname domain is a verified custom domain, this can be true"
  type = bool
  default = false
}

variable "logo" {
  description = "Path to the png image to use in the gallery for this application"
  type = string
}

variable "login_path" {
  description = "The path for logging in. The hostname is already defined."
}

variable "logout_path" {
  description = "The path for the application logout. The hostname is already defined."
  type = string
  default = "/logout"
}

variable "redirect_paths" {
  description = "List of redirect paths. The hostname is already defined."
  type = list(string)
}
