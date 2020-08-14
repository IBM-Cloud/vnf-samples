##############################################################################
# This file creates the compute instances for the solution.
# - Virtual Server using RHEL 7 custom image
# - Virtual server initialized with boot script 
##############################################################################

##############################################################################
# Read/validate sshkey
##############################################################################
data "ibm_is_ssh_key" "vnf_ssh_pub_key" {
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

resource "ibm_is_security_group" "vnf_security_group" {
  name           = "${var.vnf_security_group}"
  vpc            = "${data.ibm_is_subnet.vnf_subnet.vpc}"
  resource_group = "${data.ibm_is_subnet.vnf_subnet.resource_group}"
}

//security group rule to allow ssh
resource "ibm_is_security_group_rule" "vnf_sg_allow_ssh" {
  depends_on = ["ibm_is_security_group.vnf_security_group"]
  group     = "${ibm_is_security_group.vnf_security_group.id}"
  direction = "inbound"
  remote     = "0.0.0.0/0"
  tcp {
    port_min = 22
    port_max = 22
  }
}

//security group rule to allow all for inbound
resource "ibm_is_security_group_rule" "vnf_sg_rule_all" {
  depends_on = ["ibm_is_security_group_rule.vnf_sg_allow_ssh"]
  group     = "${ibm_is_security_group.vnf_security_group.id}"
  direction = "inbound"
  remote    = "0.0.0.0/0"
}

//security group rule to allow icmp for outbound
resource "ibm_is_security_group_rule" "vnf_sg_rule_icmp_out" {
  depends_on = ["ibm_is_security_group_rule.vnf_sg_rule_all"]
  group     = "${ibm_is_security_group.vnf_security_group.id}"
  direction = "outbound"
  remote    = "0.0.0.0/0"
  icmp {
    code = 0
    type = 8
  }
}
resource "ibm_is_instance" "vnf_vsi" {
  depends_on = ["ibm_is_security_group_rule.vnf_sg_rule_icmp_out"]
  name           = "${var.vnf_instance_name}"
  image          = "${ibm_is_image.vnf_custom_image.id}"
  profile        = "${data.ibm_is_instance_profile.vnf_profile.name}"
  resource_group = "${data.ibm_is_subnet.vnf_subnet.resource_group}"

  primary_network_interface {
    subnet = "${data.ibm_is_subnet.vnf_subnet.id}"
    security_groups = ["${ibm_is_security_group.vnf_security_group.id}"]
  }

  vpc  = "${data.ibm_is_subnet.vnf_subnet.vpc}"
  zone = "${data.ibm_is_subnet.vnf_subnet.zone}"
  keys = ["${data.ibm_is_ssh_key.vnf_ssh_pub_key.id}"]

  user_data="${data.template_file.user_data.rendered}"

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
