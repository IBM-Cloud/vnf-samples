##############################################################################
# Variable block - See each variable description
##############################################################################

##############################################################################
# vnf_cos_image_url - Vendor provided image COS url.
#                             The value for this variable is enter at offering
#                             onbaording time.This variable is hidden from the user.
##############################################################################
variable "vnf_cos_image_url" {
  default     = "cos://us-south/cos-bucket/image.qcow2"
  description = "The COS image object SQL URL for qcow2 image."
}

##############################################################################
# vnf_vpc_image_name - The name of the Custom image to be provisioned in your IBM Cloud account.
##############################################################################
variable "vnf_vpc_image_name" {
  default     = "test-custom-img"
  description = "The name of the Custom image to be provisioned in your IBM Cloud account."
}

variable "region" {
  default     = "us-south"
  description = "The value of the region where Custom image needs to be created."
}

##############################################################################
# image_operating_system - Description of underlying OS of an image.
##############################################################################
variable "image_operating_system" {
  default     = "centos-7-amd64"
  description = "Description of underlying OS of an image."
}

#####################################################################################################
# api_key - This is the ibm_cloud_api_key which should be used only while testing this code from CLI. 
# It is not needed while testing from Schematics
######################################################################################################
/*
variable "api_key" {
  default     = "ZcwWBFuTQvJAjzFssgsc9jJKraVaMI4GysFf-QazJCe5"
  description = "holds the user api key"
}*/

