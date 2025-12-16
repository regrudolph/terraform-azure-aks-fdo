############################################
# Azure equivalents for:
# - google_service_account
# - dns.admin role binding
# - workload identity bindings
############################################

# Prereqs:
# - AKS cluster has OIDC issuer enabled and workload identity enabled
# - You know the cluster OIDC issuer URL
# - Your DNS zone lives in an Azure DNS zone resource (azurerm_dns_zone)

############################
# Data / Inputs
############################

# AKS OIDC issuer URL (example: data from azurerm_kubernetes_cluster)
# data "azurerm_kubernetes_cluster" "aks" {
#   name                = var.aks_name
#   resource_group_name = var.aks_rg
# }

# If you already have it, just pass it in:
# var.aks_oidc_issuer_url

# Azure DNS Zone
# resource "azurerm_dns_zone" "primary" {
#   name                = var.dns_zone_name
#   resource_group_name = var.dns_zone_rg
# }

data "azurerm_client_config" "current" {}

############################
# cert-manager identity
############################

resource "azuread_application" "cert_manager" {
  display_name = "cert-manager"
}

resource "azuread_service_principal" "cert_manager" {
  client_id = azuread_application.cert_manager.client_id
}

# Grant cert-manager rights on the DNS zone (DNS Zone Contributor is commonly sufficient)
resource "azurerm_role_assignment" "cert_manager_dns" {
  scope                = azurerm_dns_zone.primary.id
  role_definition_name = "DNS Zone Contributor"
  principal_id         = azuread_service_principal.cert_manager.object_id
}

# Federated identity credential (Workload Identity) for cert-manager ServiceAccount
resource "azuread_application_federated_identity_credential" "cert_manager" {
  application_id = azuread_application.cert_manager.id
  display_name   = "cert-manager-sa-federation"
  description    = "AKS Workload Identity federation for cert-manager"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = var.aks_oidc_issuer_url
  subject        = "system:serviceaccount:cert-manager:cert-manager"
}

############################
# external-dns identity
############################

resource "azuread_application" "external_dns" {
  display_name = "external-dns"
}

resource "azuread_service_principal" "external_dns" {
  client_id = azuread_application.external_dns.client_id
}

resource "azurerm_role_assignment" "external_dns_dns" {
  scope                = azurerm_dns_zone.primary.id
  role_definition_name = "DNS Zone Contributor"
  principal_id         = azuread_service_principal.external_dns.object_id
}

resource "azuread_application_federated_identity_credential" "external_dns" {
  application_id = azuread_application.external_dns.id
  display_name   = "external-dns-sa-federation"
  description    = "AKS Workload Identity federation for external-dns"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = var.aks_oidc_issuer_url
  subject        = "system:serviceaccount:external-dns:external-dns"
}

############################
# Outputs (use these in Helm SA annotations)
############################

output "cert_manager_client_id" {
  value = azuread_application.cert_manager.client_id
}

output "external_dns_client_id" {
  value = azuread_application.external_dns.client_id
}
