variable "vm_name" {}

variable "additional_disk_size_gb" {
  default = 0
}

variable "resource_group" {}

variable "location" {
  default = "uksouth"
}

variable "username" {
  default = "dojenkins"
}

variable "ssh_key" {}

variable "subnet_id" {}

variable "avset_id" {}

variable "storage_account" {}

variable "diagnostics_storage_account" {}

variable "instance_count" {
  default = 1
}

variable "vm_size" {
  default = "Standard_D2_v2"
}

#TAGS
variable "product" {}

variable "env" {}

variable "tier" {
  default = "UNSET"
}

variable "ansible" {
  default = "true"
}

variable "role" {
  default = "UNSET"
}

variable "delete_os_disk_on_termination" {
  default = "true"
}

variable "delete_data_disks_on_termination" {
  default = "true"
}
