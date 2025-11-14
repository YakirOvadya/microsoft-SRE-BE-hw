variable "subscription_id" {
  type        = string
  description = "Azure subscription ID"
}

variable "tenant_id" {
  type        = string
  description = "Azure tenant ID"
}

variable "resource_group_name" {
  description = "RG name"
  default     = "hwrg"
}

variable "location" {
  description = "Azure region"
  default     = "westeurope"
}

variable "acr_name" {
  description = "ACR name"
  default     = "hwacryakir"
}

variable "aks_name" {
  description = "AKS cluster name"
  default     = "hwaks"
}

variable "aks_dns_prefix" {
  description = "AKS DNS prefix"
  default     = "mshw-aks-dns"
}