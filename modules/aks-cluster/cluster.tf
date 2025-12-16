resource "azurerm_kubernetes_cluster" "primary" {
  name                = "${var.project_id}-aks"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "${var.project_id}-aks"

  # AKS requires a default node pool (you can keep it minimal and add your "real" pool separately)
  default_node_pool {
    name                 = "system"
    vm_size              = "Standard_D2s_v3"
    node_count           = var.initial_node_count
    vnet_subnet_id       = var.subnet_id
    orchestrator_version = var.kubernetes_version
    type                 = "VirtualMachineScaleSets"
  }

  identity {
    type = "SystemAssigned"
  }

  # Networking (maps to "network/subnetwork" concepts)
  network_profile {
    network_plugin = "azure"
    # network_policy = "azure" # optional
  }

  # Equivalent to disabling client cert issuance on control plane auth
  azure_active_directory_role_based_access_control {
    managed = true
    # tenant_id              = var.tenant_id        # optional
    # admin_group_object_ids = var.admin_group_ids  # optional
  }

  # If you truly want "open API server" like 0.0.0.0/0 on GKE:
  # api_server_authorized_ip_ranges = ["0.0.0.0/0"]
  #
  # Strongly recommended: restrict this instead of open access.

  lifecycle {
    create_before_destroy = true
  }
}

# Separately managed user node pool (equivalent to google_container_node_pool)
resource "azurerm_kubernetes_cluster_node_pool" "primary_nodes" {
  name                  = "usernp"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.primary.id
  vm_size               = "Standard_D2s_v3"
  node_count            = var.node_pool_count
  mode                  = "User"
  vnet_subnet_id        = var.subnet_id
  orchestrator_version  = var.kubernetes_version

  # Tags roughly map to Azure tags/labels
  tags = {
    role    = "aks-node"
    cluster = "${var.project_id}-aks"
  }

  lifecycle {
    create_before_destroy = true
  }
}