
variable "azure_location" {
  description = "azure_location"
  type = string
  default = "eastus"
}

variable "env_location" {
  description = "shortlocation"
  type = string
  default = "use11"
}

variable "env_shortname" {
  description = "shortname"
  type = string
  default = "asdigiv1"
}

variable "env_vnet_addr" {
  description = "vnet_address_space"
  type = list
  default = ["10.10.0.0/24"]
}

variable "env_appsubnet_addr" {
  description = "appsubnet_address_space"
  type = list
  default = ["10.10.0.96/27"]
}
