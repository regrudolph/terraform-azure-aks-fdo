output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.primary.name
}

output "aks_cluster_location" {
  value = azurerm_kubernetes_cluster.primary.location
}

output "aks_cluster_api_server" {
  value = azurerm_kubernetes_cluster.primary.kube_config.host
}

output "aks_cluster_ca_certificate" {
  value = base64decode(
    azurerm_kubernetes_cluster.primary.kube_config.cluster_ca_certificate
  )
}
