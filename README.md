# tf-azure-auth
Terraform code to assist in creating SAML and OIDC application integrations with Azure.

The emphasis is on RBAC. App roles are used rather than AzureAD groups. You can still use groups,
but they must be assigned to the relevant app roles.
