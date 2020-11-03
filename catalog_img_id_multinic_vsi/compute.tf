##############################################################################
# This file creates the compute instances for the solution.
# - Virtual Server using Ubuntu 18.04 custom image
##############################################################################

locals {
  secondary_subnets = compact(list(var.secondary_subnet_id_1 , var.secondary_subnet_id_2, var.secondary_subnet_id_3, var.secondary_subnet_id_4))
}

##############################################################################
# lookup image name for a custom image in region if we need it
##############################################################################
data "ibm_is_image" "vnf_custom_image" {
  name = "${var.image_name}"
}

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

locals {
# custom image takes priority over public image
  image_id = data.ibm_is_image.vnf_custom_image.id == null ? lookup(local.image_map[var.image_name], data.ibm_is_region.region.name) : data.ibm_is_image.vnf_custom_image.id
}

##############################################################################
# Create Ubuntu 18.04 virtual server.
##############################################################################

//security group
resource "ibm_is_security_group" "vnf_security_group" {
  name           = "${var.vnf_security_group}"
  vpc            = "${data.ibm_is_subnet.vnf_primary_subnet.vpc}"
  resource_group = "${data.ibm_is_subnet.vnf_primary_subnet.resource_group}"
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
resource "ibm_is_security_group_rule" "vnf_sg_rule_in_all" {
  depends_on = ["ibm_is_security_group_rule.vnf_sg_allow_ssh"]
  group     = "${ibm_is_security_group.vnf_security_group.id}"
  direction = "inbound"
  remote    = "0.0.0.0/0"
}

//security group rule to allow all for outbound
resource "ibm_is_security_group_rule" "vnf_sg_rule_out_all" {
  depends_on = ["ibm_is_security_group_rule.vnf_sg_rule_in_all"]
  group     = "${ibm_is_security_group.vnf_security_group.id}"
  direction = "outbound"
  remote    = "0.0.0.0/0"
}

//vnf instance 
resource "ibm_is_instance" "vnf_vsi" {
  depends_on = ["ibm_is_security_group_rule.vnf_sg_rule_out_all"]
  name           = "${var.vnf_instance_name}"
  image          = local.image_id
  profile        = "${data.ibm_is_instance_profile.vnf_profile.name}"
  resource_group = "${data.ibm_is_subnet.vnf_primary_subnet.resource_group}"

  primary_network_interface {
    name = "eth0"
    subnet = "${data.ibm_is_subnet.vnf_primary_subnet.id}"
    security_groups = ["${ibm_is_security_group.vnf_security_group.id}"]
  }
  
  dynamic "network_interfaces" {
    for_each = local.secondary_subnets
    content {
    name = format("eth%d", (network_interfaces.key+1))
    subnet = network_interfaces.value
    security_groups = ["${ibm_is_security_group.vnf_security_group.id}"]
    }
  }
  
  vpc  = "${data.ibm_is_subnet.vnf_primary_subnet.vpc}"
  zone = "${data.ibm_is_subnet.vnf_primary_subnet.zone}"
  keys = ["${data.ibm_is_ssh_key.vnf_ssh_pub_key.id}"]


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
