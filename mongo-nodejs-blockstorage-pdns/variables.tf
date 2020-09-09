##############################################################################
# Variable block - See each variable description
##############################################################################

##############################################################################
# block storage volume 
##############################################################################
variable "bs_volume_name"{
  default = "block-storage-vsi-server"
  description =" The block storage volume name"
}

variable "dns_record_name"{
  default = "testc"
  description = "DNS Record name"
}

variable "dns_zone_name"{
  default = "testpdns.com"
  description = "DNS zone name"
}

variable "vsi_client_name"{
  default = "client-1"
  description = "The VSI name of client"
}

variable "vsi_server_name_1"{
  default = "server-1"
  description = "The VSI name of server"
}

variable "vsi_server_name_2"{
  default = "server-2"
  description = "The VSI name of server"
}

variable "fip_client_name"{
  default = "fip_client_1"
  description = "The Floating ip of client VSI"
}

variable "fip_server_name_1"{
  default = "fip_server_1"
  description = "The Floating ip of server 1 VSI"
}

variable "fip_server_name_2"{
  default = "fip_server_2"
  description = "The Floating ip of server 2 VSI"
}


variable "ssh_key_name" {
  default     = ""
  description = "The name of the public SSH key to be used when provisining Ubuntu VSI."
}

variable "vpc_name" {
  default     = ""
  description = "The name of the VPC."
}

variable "subnet_name" {
  default     = ""
  description = "The name of the subnet."
}

variable "sec_group_name" {
  default     = ""
  description = "The name of the security group."
}
