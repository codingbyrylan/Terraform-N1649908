variable "humber_id" {
  description = "The Humber ID to be used for naming resources"
  type        = string
}

variable "location" {
  description = "The Azure region to deploy resources"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "tags" {
  description = "A map of tags to be applied to the resources"
  type        = map(string)
}

# Optional: Public IP allocation method (if you want to make it flexible)
variable "public_ip_allocation_method" {
  description = "The allocation method for the public IP (Static or Dynamic)"
  type        = string
  default     = "Static"
}

variable "vm_nics" {
  description = "List of network interface IDs for the VMs"
  type        = list(string)
}