##############################################################################
# This file creates custom image using RHEL 7 qcow2 image hosted in COS
#
##############################################################################

locals {
  image_url = "cos://${var.region}/${var.vnf_bucket_base_name}-${var.region}/${var.vnf_cos_image_name}"
}

# Generating random ID
resource "random_uuid" "test" { }

resource "ibm_is_image" "vnf_custom_image" {
  depends_on       = ["random_uuid.test"]
  href             = "${local.image_url}"
  name             = "${var.vnf_vpc_image_name}-${substr(random_uuid.test.result,0,8)}"
  operating_system = "red-7-amd64"
  resource_group = "${data.ibm_resource_group.rg.id}"

  timeouts {
    create = "30m"
    delete = "10m"
  }
}

