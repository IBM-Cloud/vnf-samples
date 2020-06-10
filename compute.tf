##############################################################################
# This file creates the compute instances for the solution.
# - Virtual Server using RHEL 7 custom image
# - Virtual server initialized with boot script 
##############################################################################

##############################################################################
# Read/validate sshkey
##############################################################################
data "ibm_is_ssh_key" "rhel7_ssh_pub_key" {
  name = "${var.ssh_key_name}"
}

##############################################################################
# Read/validate vsi profile
##############################################################################
data "ibm_is_instance_profile" "vnf_profile" {
  name = "${var.vnf_profile}"
}

##############################################################################
# Create RHEL 7 virtual server.
##############################################################################


data "template_file" "user_data" {
  template = "${file("${path.module}/boot.tpl")}"
  vars = {
    ssh_key = "${var.ssh_key}"
  }
}

resource "ibm_is_instance" "rhel7_vsi" {
  name           = "${var.vnf_instance_name}"
  image          = "${data.ibm_is_image.rhel7_custom_image.id}"
  profile        = "${data.ibm_is_instance_profile.vnf_profile.name}"
  resource_group = "${data.ibm_resource_group.rg.id}"

  primary_network_interface {
    subnet = "${data.ibm_is_subnet.rhel7_subnet1.id}"
  }

  vpc  = "${data.ibm_is_vpc.rhel7_vpc.id}"
  zone = "${data.ibm_is_zone.zone.name}"
  keys = ["${data.ibm_is_ssh_key.rhel7_ssh_pub_key.id}"]

  user_data=data.template_file.user_data.rendered

  //User can configure timeouts
  timeouts {
    create = "10m"
    delete = "10m"
  }
  # Hack to handle some race condition; will remove it once have root caused the issues.
  provisioner "local-exec" {
    command = "sleep 30"
  }
}
