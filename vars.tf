variable "location" {
  description = "The Azure region to deploy resources in"
  default     = "West Europe"
}

variable "resource_group_name" {
  description = "The name of the resource group"
  default     = "Azuredevops"
}

variable "vnet_name" {
  description = "The name of the Virtual Network"
  default     = "myapp-network"
}

variable "subnet_name" {
  description = "The name of the Subnet"
  default     = "internal"
}

variable "nsg_name" {
  description = "The name of the Network Security Group"
  default     = "myapp-nsg"
}

variable "lb_name" {
  description = "The name of the Load Balancer"
  default     = "myapp-lb"
}

variable "availability_set_name" {
  description = "The name of the Availability Set"
  default     = "myapp-availability-set"
}

variable "vm_count" {
  description = "The number of Virtual Machines to create"
  default     = 2
}

variable "vm_size" {
  description = "The size of the Virtual Machines"
  default     = "Standard_B1s"
}

variable "admin_username" {
  description = "Admin username for the VMs"
  default     = "adminuser"
}

variable "admin_password" {
  description = "Admin password for the VMs"
  default     = "P@ssword123!"
}

variable "packer_image_name" {
  description = "The name of the Packer image"
  default     = "myPackerImage_2"
}

variable "tags" {
  description = "Tags to be applied to resources"
  default = {
    Environment = "Development"
    Department  = "IT"
  }
}
