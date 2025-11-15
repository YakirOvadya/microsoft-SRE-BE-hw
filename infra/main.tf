# ---------------------------------------------------------------------------------------------------------
# Terraform provider + authentication

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.48"
    }
  }
}


# ---------------------------------------------------------------------------------------------------------
# Provider configuration

provider "azurerm" {
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  features {}
}

provider "azuread" {
  tenant_id = var.tenant_id
}

# Read current logged in user (needed for tenant/sub)
data "azurerm_client_config" "current" {}

# ---------------------------------------------------------------------------------------------------------
# RG

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# ---------------------------------------------------------------------------------------------------------
# ACR

resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = false
}

# ---------------------------------------------------------------------------------------------------------
# AKS

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  dns_prefix          = var.aks_dns_prefix

  default_node_pool {
    name       = "system"
    node_count = 1
    vm_size    = "Standard_B2s"
  }

  identity {
    type = "SystemAssigned"
  }

  role_based_access_control_enabled = true
}

resource "azurerm_kubernetes_cluster_node_pool" "apps" {
  name                  = "apps"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id

  vm_size    = "Standard_B2s"
  node_count = 1
  mode       = "User"
}

# ---------------------------------------------------------------------------------------------------------
# Allow AKS to pull images from ACR

resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id         = azurerm_kubernetes_cluster.aks.identity[0].principal_id
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.acr.id
}

# ---------------------------------------------------------------------------------------------------------
# GitHub Actions - sp for my CI-CD

resource "azuread_application" "github_sp_app" {
  display_name = "aks-github-deployer"

#  lifecycle {
#    prevent_destroy = true
#  }
}

resource "azuread_service_principal" "github_sp" {
  client_id = azuread_application.github_sp_app.client_id

#  lifecycle {
#    prevent_destroy = true
#  }
}

resource "azuread_service_principal_password" "github_sp_password" {
  service_principal_id = azuread_service_principal.github_sp.id
#  lifecycle {
#    prevent_destroy = true
#  }
}

# Role assignment for acr push
resource "azurerm_role_assignment" "github_acr_push" {
  principal_id         = azuread_service_principal.github_sp.id
  role_definition_name = "AcrPush"
  scope                = azurerm_container_registry.acr.id
}

# Role assignment for aks admin
resource "azurerm_role_assignment" "github_aks_admin" {
  principal_id         = azuread_service_principal.github_sp.id
  role_definition_name = "Azure Kubernetes Service Cluster Admin Role"
  scope                = azurerm_kubernetes_cluster.aks.id
}

resource "azurerm_role_assignment" "github_aks_rbac_admin" {
  principal_id         = azuread_service_principal.github_sp.id
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  scope                = azurerm_kubernetes_cluster.aks.id
}

resource "azurerm_role_assignment" "aks_kubelet_acr_pull" {
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.acr.id
}