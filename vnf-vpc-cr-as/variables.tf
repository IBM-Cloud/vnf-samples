variable "region" {
  default     = "us-south"
  description = "The VPC Region that you want your VPC, networks and the F5 virtual server to be provisioned in. To list available regions, run `ibmcloud is regions`."
}

variable "generation" {
  default     = 2
  description = "The VPC Generation to target. Valid values are 2 or 1."
}

variable "resource_group" {
  default     = "Default"
  description = "The resource group to use. If unspecified, the account's default resource group is used."
}

variable "zone" {
  default     = "us-south-1"
  description = "The zone to use. If unspecified, the us-south-1 is used."
}

variable "vpc" {
  default     = "myvpc"
  description = "The vpc to use. If unspecified, 'myvpc' is used."
}

variable "ssh_key" {
  default     = "my-ssh-key"
  description = "The ssh key to use. If unspecified, 'my-ssh-key' is used."
}

variable "subnet1_ipv4_cidr_block" {
  default     = ""
  description = "subnet1 ipv4 cidr block."
}

variable "subnet2_ipv4_cidr_block" {
  default     = ""
  description = "subnet2 ipv4 cidr block."
}

variable "subnet3_ipv4_cidr_block" {
  default     = ""
  description = "subnet3 ipv4 cidr block."
}
