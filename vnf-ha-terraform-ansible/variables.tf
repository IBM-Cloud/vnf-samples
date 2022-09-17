variable "TF_VERSION" {
 default = "0.12"
 description = "terraform engine version to be used in schematics"
}

variable "generation" {
  default     = 2
  description = "The VPC Generation to target. Valid values are 2 or 1."
}

variable "region" {
  default     = "us-south"
  description = "The VPC Region that you want your VSI to be provisioned in. To list available regions, run `ibmcloud is regions`."
}

variable "rias_api_url" {
  default     = "https://us-south.iaas.cloud.ibm.com"
  description = "The public RIAS endpoint url of VPC. This is used by vpc sdk."
}

variable "apikey" {
  default     = ""
  description = "The apikey of IBM Cloud account. This is used by vpc sdk."
}

variable "ssh_key" {
  default     = ""
  description = "The public ssh key to use. The ssh key is added to VSI."
}

variable "private_ssh_key" {
  default     = "--BEGIN--"
  description = "The private ssh key to configure VSI. The private ssh key should be of the public ssh key."
}

variable "failover_function_subnet_id" {
  default     = ""
  description = "The ubuntu VSI subnet id."
}

variable "mgmt_ip1" {
  default     = ""
  description = "The management IP 1 of HA pair."
}

variable "ext_ip1" {
  default     = ""
  description = "The external IP 1 of HA pair."
}

variable "mgmt_ip2" {
  default     = ""
  description = "The management IP 2 of HA pair."
}

variable "ext_ip2" {
  default     = ""
  description = "The external IP 2 of HA pair."
}

variable "vnf_mgmt_ipv4_cidr_block" {
  default     = ""
  description = "VNF Management subnet ipv4 cidr block. Only this cidr block is allowed to access fail over function."
}

variable "ha_password1" {
  default     = ""
  description = "HA instance1 Password."
}

variable "ha_password2" {
  default     = ""
  description = "HA instance2 Password."
}
