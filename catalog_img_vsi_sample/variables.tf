##############################################################################
# Variable block - See each variable description
##############################################################################


##############################################################################
# subnet_id - Subnet where resources are to be provisioned.
##############################################################################
variable "subnet_id"{
  default = "0716-4628836b-003d-4368-b8b7-135f57eb134a"
  description = "The id of the subnet to which Ubuntu VSI's interface belongs to"
}

##############################################################################
# ssh_key_name - The name of the public SSH key to be used when provisining Ubuntu VSI.
##############################################################################
variable "ssh_key_name" {
  default = "malar-new-ssh-key"
  description = "The name of the public SSH key to be used when provisining Ubuntu VSI."
}

##############################################################################
# vnf_vpc_image_name - The name of the Ubuntu catalog image to be provisioned in your IBM Cloud account.
##############################################################################

variable "vnf_vpc_image_name" {
  default = "ibm-ubuntu-20-04-3-minimal-amd64-2"
  description = "The name of the Ubuntu catalog image to be provisioned in your IBM Cloud account."
}

##############################################################################
# vnf_vpc_instance_name - The name of your Ubuntu Virtual Server to be provisioned
##############################################################################
variable "vnf_instance_name" {
  default     = "ubuntu20-04-vsi"
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
variable "api_key" {
  default     = ""
  description = "holds the user api key"
}

##############################################################################
# vnf_securtiy_group - The security group to which the VSI interface belongs to.
##############################################################################
variable "vnf_security_group" {
  default     = "ubuntu-security-group-1"
  description = "The security group for VNF VPC"
}
