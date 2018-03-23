variable "subscription_id" {}

variable "ssh_pubkey" {}

variable "azure_region" {
  default = "uksouth"
}

variable "test_name" {
  default = "sandbox-tf-module-vm"
}
