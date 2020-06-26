##############################################################################
# Variable block - See each variable description
##############################################################################

##############################################################################
# vnf_bucket_base_name - The base name of the bucket which holds the qcow2 Image, For Ex. If bucket name is vnf-rhel-us-south vnf-rhel should be the input here, hyphen(-) and region name will be added by the script before copy.
##############################################################################
variable "vnf_bucket_base_name" {
  default = ""
  description ="The base name of the bucket which holds the qcow2 Image, For Ex. If bucket name is vnf-rhel-us-south vnf-rhel should be the input here, hyphen(-) and region name will be added by the script before copy"
}

##############################################################################
# vnf_cos_image_name - The name of the qcow2 Image name stored in the COS Bucket.
##############################################################################
variable "vnf_cos_image_name" {
  default=""
  description = "The name of the qcow2 Image name"
}

##############################################################################
# zone - VPC zone where resources are to be provisioned.
##############################################################################
variable "zone" {
  default     = "us-south-3"
  description = "The VPC Zone that you want your VPC networks and virtual servers to be provisioned in. To list available zones, run `ibmcloud is zones`."
}

##############################################################################
# vpc_name - VPC where resources are to be provisioned.
##############################################################################
variable "vpc_name" {
  default     = ""
  description = "The name of your VPC where RHEL7 VSI is to be provisioned."
}

##############################################################################
# subnet_name - Subnet where resources are to be provisioned.
##############################################################################
variable "subnet_id"{
  default = ""
  description =" The id of the subnet where RHEL7 VSI to be provisioned."
}
##############################################################################
# ssh_key_name - The name of the public SSH key to be used when provisining RHEL7 VSI.
##############################################################################
variable "ssh_key_name" {
  default     = ""
  description = "The name of the public SSH key to be used when provisining RHEL7 VSI."
}

##############################################################################
# vnf_vpc_image_name - The name of the RHEL7 custom image to be provisioned in your IBM Cloud account.
##############################################################################
variable "vnf_vpc_image_name" {
  default     = "rhel7"
  description = "The name of the RHEL7 custom image to be provisioned in your IBM Cloud account."
}

##############################################################################
# vnf_vpc_image_name - The name of your RHEL7 Virtual Server to be provisioned
##############################################################################
variable "vnf_instance_name" {
  default     = "rhel7-vsi"
  description = "The name of your RHEL7 Virtual Server to be provisioned."
}

##############################################################################
# vnf_profile - The profile of compute CPU and memory resources to be used when provisioning RHEL7 VSI.
##############################################################################
variable "vnf_profile" {
  default     = "bx2-2x8"
  description = "The profile of compute CPU and memory resources to be used when provisioning RHEL7 VSI. To list available profiles, run `ibmcloud is instance-profiles`."
}

variable "ssh_key" {
  default     = ""
  description = "Optional. The value of the ssh key to be used during cloud-init."
}

variable "region" {
  default     = "us-south"
  description = "Optional. The value of the region of VPC."
}

##############################################################################
# resource_group - The resource group to which the VPC belongs to.
##############################################################################
variable "resource_group" {
  default     = "Default"
  description = "Optional. The value of the resource group of VPC."
}

##############################################################################
# vnf_securtiy_group - The security group to which the VSI interface belongs to.
##############################################################################
variable "vnf_security_group" {
  default     = "rhel7-security-group"
  description = "The security group for VNF VPC"
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