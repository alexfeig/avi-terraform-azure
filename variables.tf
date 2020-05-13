provider "azurerm" {
  features {
  }
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}

variable "subscription_id" {
  description = "Azure Subscription ID"
}

variable "tenant_id" {
  description = "Azure Tenant ID"
}

variable "resource_group" {
  description = "Resource group used for provisioning"
  type        = string
}

variable "ansible_playbook_path" {
  description = "Path of Ansible Playbook called by azure_post_provision.tf"
  type        = string
}

variable "azure_region" {
  description = "Azure region to deploy to"
  type        = string
  default     = "East US"
}

variable "project_name" {
  description = "Used to prepend Azure objects - e.g. PROJECT-tf-web"
  type        = string
}

variable "vnet_address" {
  description = "Virtual Network subnet. If this is changed, you must change the Ansible playbook"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "web_instance_size" {
  description = "Web server instance size"
  type        = string
  default     = "Standard_B1s"
}

variable "controller_instance_size" {
  description = "Avi controller instance size"
  type        = string
  default     = "Standard_D8s_v3"
}

variable "admin_username" {
  description = "Webserver username"
  type        = string
}

variable "admin_password" {
  description = "Controller admin password"
  type        = string
}

variable "web_count" {
  description = "Number of webservers to provision"
  type        = string
  default     = "3"
}

variable "avi_username" {
  description = "Avi controller SSH login user"
  type        = string
}

variable "controller_version" {
  description = "Avi controller version"
  type        = string
  default     = "17.2.14"
}

