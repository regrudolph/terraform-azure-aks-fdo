# terraform-azure-aks-fdo
Terraform AKS Deployment and FDO installation
Terraform Enterprise on GKE
This repository sets up Terraform Enterprise (TFE) on Google Kubernetes Engine (GKE) in Google Cloud Platform (GCP).

Note to self to properly link and credit Patrick Munne & whoever else helped write the GCP openshift doc as I used it extensively to build this.

Setup Process

Before starting, you will need:

An Azure Subscription

An Azure Active Directory (Entra ID) Service Principal

Appropriate credentials for Terraform Cloud

Access to Azure DNS

Azure Subscription and Access

Request an Azure subscription through your internal access request system (equivalent to Doormat).

Ensure the request includes DNS permissions.

DNS access is critical—if a DNS zone is not visible later, the subscription may need to be reissued with proper permissions.

Verify access to the Azure Portal

Log in to https://portal.azure.com
 to confirm the subscription is active and accessible.

This step should be done first, as subscription provisioning can take time.

Confirm DNS availability

In the Azure Portal, search for Azure DNS.

Verify that a DNS zone exists and take note of the domain name.

If no DNS zone is present, you may need to request one or have it created.

Set Up Azure Service Principal for Terraform Cloud

Terraform Cloud will authenticate to Azure using a Service Principal.

Install and Authenticate Azure CLI
az login
az account set --subscription <SUBSCRIPTION_ID>


Verify the correct subscription is selected:

az account show

Create a Service Principal

Create a Service Principal with Contributor access (adjust role if your org requires least privilege):

az ad sp create-for-rbac \
  --name terraform-cloud \
  --role Contributor \
  --scopes /subscriptions/<SUBSCRIPTION_ID> \
  --sdk-auth


⚠️ Save the output securely. It contains:

clientId

clientSecret

tenantId

subscriptionId

These values will be required in Terraform Cloud.

(Optional) Store Credentials Securely

You may store these credentials in a secure location (password manager or vault).
In Terraform Cloud, they will typically be added as workspace variables:

ARM_CLIENT_ID

ARM_CLIENT_SECRET

ARM_TENANT_ID

ARM_SUBSCRIPTION_ID

Provision the Terraform Cloud Workspace

Navigate to the Terraform Cloud private registry module (Azure equivalent of the GCP module):

https://app.terraform.io/app/hashicorp-support-eng/registry/modules/private/...


Click Provision Workspace in the top-right corner.

Configure module inputs

Subscription ID

Resource Group

Region

DNS-related inputs (zone name, resource group, etc.)

Click Next: Workspace settings

Provide a workspace name

Optionally associate the workspace with a Terraform Cloud Project

Add a description if desired

Choose the apply method (Auto-apply or Manual)

Click Create workspace to finalize the setup.