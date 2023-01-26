##############################################################################
# This is default entrypoint.
#  - Ensure user provided region is valid
##############################################################################

variable "generation" {
  default     = 2
  description = "The VPC Generation to target. Valid values are 2 or 1."
}

provider "ibm" {
  /* Uncomment ibmcloud_api_key while testing from CLI */
  ibmcloud_api_key      = ""  
  generation            = "${var.generation}" 
  region                = "${var.region}"
  ibmcloud_timeout      = 300
}

##############################################################################
# Read/validate Region
##############################################################################
data "ibm_is_region" "region" {
  name = "${var.region}"
}

