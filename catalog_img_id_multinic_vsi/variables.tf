##############################################################################
# Variable block - See each variable description
##############################################################################

##############################################################################
# subnet_id - Subnet where resources are to be provisioned.
##############################################################################
variable "primary_subnet_id"{
  default = ""
  description =" The id of the subnet to which Ubuntu VSI's interface belongs to"
}

variable "secondary_subnet_id_1"{
  default = ""
  description =" The id of the secondary subnet to which Ubuntu VSI's interface belongs to"
}

variable "secondary_subnet_id_2"{
  default = ""
  description =" The id of the secondary subnet to which Ubuntu VSI's interface belongs to"
}

variable "secondary_subnet_id_3"{
  default = ""
  description =" The id of the secondary subnet to which Ubuntu VSI's interface belongs to"
}

variable "secondary_subnet_id_4"{
  default = ""
  description =" The id of the secondary subnet to which Ubuntu VSI's interface belongs to"
}

##############################################################################
# ssh_key_name - The name of the public SSH key to be used when provisining Ubuntu VSI.
##############################################################################
variable "ssh_key_name" {
  default     = ""
  description = "The name of the public SSH key to be used when provisining Ubuntu VSI."
}

##############################################################################
# image_name - The name of the f5 big ip image name. Valid values are "bigip-14-1-2-6-0-0-2-all-1slot", "bigip-14-1-2-6-0-0-2-ltm-1slot", "bigip-15-1-0-4-0-0-6-all-1slot", "bigip-15-1-0-4-0-0-6-ltm-1slot" 
##############################################################################
variable "image_name" {
  default     = "bigip-14-1-2-6-0-0-2-all-1slot"
  description = "The name of the f5 big ip image name. Valid values are bigip-14-1-2-6-0-0-2-all-1slot, bigip-14-1-2-6-0-0-2-ltm-1slot, bigip-15-1-0-4-0-0-6-all-1slot, bigip-15-1-0-4-0-0-6-ltm-1slot."
}

##############################################################################
# vnf_vpc_instance_name - The name of your Ubuntu Virtual Server to be provisioned
##############################################################################
variable "vnf_instance_name" {
  default     = "ubuntu18-04-vsi"
  description = "The name of your Ubuntu Virtual Server to be provisioned."
}

##############################################################################
# vnf_profile - The profile of compute CPU and memory resources to be used when provisioning Ubuntu VSI.
##############################################################################
variable "vnf_profile" {
  default     = "bx2-2x8"
  description = "The profile of compute CPU and memory resources to be used when provisioning Ubuntu VSI. To list available profiles, run `ibmcloud is instance-profiles`."
}

variable "region" {
  default     = "us-south"
  description = "Optional. The value of the region of VPC."
}

#####################################################################################################
# api_key - This is the ibm_cloud_api_key which should be used only while testing this code from CLI. 
# It is not needed while testing from Schematics
######################################################################################################
/*
variable "api_key" {
  default     = ""
  description = "holds the user api key"
}*/

##############################################################################
# vnf_securtiy_group - The security group to which the VSI interface belongs to.
##############################################################################
variable "vnf_security_group" {
  default     = "ubuntu-security-group"
  description = "The security group for VNF VPC"
}
