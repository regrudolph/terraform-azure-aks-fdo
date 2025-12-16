resource "kubernetes_namespace" "cert-manager" {
  metadata {
    name = "cert-manager"
  }

  depends_on = [
    azurerm_kubernetes_cluster.primary
  ]
}

resource "kubernetes_namespace" "ingress-nginx" {
  metadata {
    name = "ingress-nginx"
  }

  depends_on = [
    azurerm_kubernetes_cluster.primary
  ]
}

resource "kubernetes_namespace" "external-dns" {
  metadata {
    name = "external-dns"
  }

  depends_on = [
    azurerm_kubernetes_cluster.primary
  ]
}
