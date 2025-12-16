############### Helm Releases (Azure / AKS) ###############

# cert-manager
resource "helm_release" "cert-manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "1.17.2"
  namespace  = kubernetes_namespace.cert-manager.metadata[0].name

  values = [
    yamlencode({
      installCRDs = true
      extraArgs = [
        "--dns01-recursive-nameservers-only",
        "--dns01-recursive-nameservers=1.1.1.1:53,8.8.8.8:53",
      ]
      serviceAccount = {
        create = true
        annotations = {
          # AKS Workload Identity: client ID of the Azure AD application (or user-assigned managed identity)
          "azure.workload.identity/client-id" = var.cert_manager_client_id
        }
      }
    })
  ]
}

# ingress-nginx (no cloud-specific changes required)
resource "helm_release" "ingress-nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.12.2"
  namespace  = kubernetes_namespace.ingress-nginx.metadata[0].name
}

# external-dns (Azure DNS)
resource "helm_release" "external-dns" {
  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  version    = "1.16.1"
  namespace  = kubernetes_namespace.external-dns.metadata[0].name

  values = [
    yamlencode({
      extraArgs = [
        "--txt-prefix=extdns-%%{record_type}.",
        "--provider=azure",
        "--interval=1h",
        "--trigger-loop-on-event=true",
        "--policy=sync",
        # Azure DNS specifics
        "--azure-resource-group=${var.azure_dns_resource_group}",
        "--azure-subscription-id=${var.azure_subscription_id}",
        # Set to true if your Azure DNS zone is in a different resource group than your cluster
        "--azure-resource-group-enabled=true",
      ]

      serviceAccount = {
        create = true
        annotations = {
          # AKS Workload Identity client ID for external-dns
          "azure.workload.identity/client-id" = var.external_dns_client_id
        }
      }
    })
  ]
}

############### cert-manager ClusterIssuer (Azure DNS) ###############
resource "kubectl_manifest" "clusterissuer" {
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-dns01
spec:
  acme:
    server: ${var.acme_server_url}
    email: ${var.certificate_email}
    privateKeySecretRef:
      name: letsencrypt-dns01
    solvers:
    - dns01:
        azureDNS:
          subscriptionID: "${var.azure_subscription_id}"
          tenantID: "${var.azure_tenant_id}"
          resourceGroupName: "${var.azure_dns_resource_group}"
          hostedZoneName: "${var.azure_dns_zone_name}"
          environment: AzurePublicCloud
          managedIdentity:
            clientID: "${var.cert_manager_client_id}"
YAML

  depends_on = [helm_release.cert-manager]
}
