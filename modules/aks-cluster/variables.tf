variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name for the AKS cluster and related resources"
  type        = string
}

variable "location" {
  description = "Azure region where the AKS cluster is deployed"
  type        = string
}

variable "initial_node_count" {
  description = "Initial number of nodes in the AKS default node pool"
  type        = number
  default     = 1
}

variable "node_pool_count" {
  description = "Number of nodes in the AKS node pool"
  type        = number
  default     = 1
}

variable "vnet_name" {
  description = "Virtual Network name for the AKS cluster"
  type        = string
}

variable "subnet_name" {
  description = "Subnet name used by the AKS cluster"
  type        = string
}

variable "acme_server_url" {
  description = "ACME server URL for Let's Encrypt"
  type        = string
}

variable "certificate_email" {
  description = "Email address to register the Let's Encrypt certificate"
  type        = string
}
