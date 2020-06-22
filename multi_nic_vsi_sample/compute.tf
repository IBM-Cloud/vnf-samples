##############################################################################
# This file creates the compute instances for the solution.
# - Virtual Server using Ubuntu 18.04 custom image
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
# Create Ubuntu 18.04 virtual server.
##############################################################################

//security group
resource "ibm_is_security_group" "vnf_security_group" {
  name           = "${var.vnf_security_group}"
  vpc            = "${data.ibm_is_vpc.vnf_vpc.id}"
  resource_group = "${data.ibm_resource_group.rg.id}"
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

//vnf instance 
resource "ibm_is_instance" "vnf_vsi" {
  depends_on = ["ibm_is_security_group_rule.vnf_sg_rule_icmp_out"]
  name           = "${var.vnf_instance_name}"
  image          = "${ibm_is_image.vnf_custom_image.id}"
  profile        = "${data.ibm_is_instance_profile.vnf_profile.name}"
  resource_group = "${data.ibm_resource_group.rg.id}"

  primary_network_interface {
    name = "eth0"
    subnet = "${data.ibm_is_subnet.vnf_subnet1.id}"
    security_groups = ["${ibm_is_security_group.vnf_security_group.id}"]
  }
  
  network_interfaces {
    name   = "eth1"
    subnet = "${data.ibm_is_subnet.vnf_subnet2.id}"
    #if vnf_security_group need to be added in this interface then uncomment below line
    //security_groups = ["${ibm_is_security_group.vnf_security_group.id}"]
  }

  vpc  = "${data.ibm_is_vpc.vnf_vpc.id}"
  zone = "${data.ibm_is_zone.zone.name}"
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
