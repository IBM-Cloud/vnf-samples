##############################################################################
# This file creates custom image using Ubuntu 18.04 qcow2 image hosted in COS
#
##############################################################################


resource "ibm_is_image" "vnf_custom_image" {
  href             = "${var.vnf_cos_image_url}"
  name             = "${var.vnf_vpc_image_name}"
  operating_system = "${var.image_operating_system}"
  #resource_group   = "${var.resource_group}"

  timeouts {
    create = "30m"
    delete = "10m"
  }
}
