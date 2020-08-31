i###
#1 Setting the provider plugin for Terraform i.e. IBM
###

provider "ibm" {
  generation = 2
  region     = "us-south"
}

###
#2 Create a VPC
###

data "ibm_resource_group" "rg" {
  name = "Default"
}

resource "ibm_is_vpc" "test_schematics_demo_vpc" {
  depends_on     = [data.ibm_resource_group.rg]
  name           = "test-schematics-demo-vpc"
  resource_group = data.ibm_resource_group.rg.id
}

###
#3 Create a Subnet for the VPC VSI resources
###

resource "ibm_is_subnet" "test_schematics_demo_subnet" {
  name            = "test-schematics-demo-subnet"
  vpc             = ibm_is_vpc.test_schematics_demo_vpc.id
  zone            = "us-south-1"
  ipv4_cidr_block = "10.240.0.0/24"
}

###
#4 Create a Server & the Client with required the Security Group rules
###

resource "ibm_is_security_group" "test_schematics_demo_sg" {
  name           = "test-schematics-demo-sg"
  vpc            = ibm_is_vpc.test_schematics_demo_vpc.id
  resource_group = data.ibm_resource_group.rg.id
}

resource "ibm_is_security_group_rule" "test_schematics_demo_sg_rule_ssh" {
  depends_on = [ibm_is_security_group.test_schematics_demo_sg]
  group      = ibm_is_security_group.test_schematics_demo_sg.id
  direction  = "inbound"
  remote     = "0.0.0.0/0"
  tcp {
    port_min = 22
    port_max = 22
  }
}

resource "ibm_is_security_group_rule" "test_schematics_demo_sg_rule_all_in" {
  depends_on = [ibm_is_security_group_rule.test_schematics_demo_sg_rule_ssh]
  group      = ibm_is_security_group.test_schematics_demo_sg.id
  direction  = "inbound"
  remote     = "0.0.0.0/0"
}

resource "ibm_is_security_group_rule" "test_schematics_demo_sg_rule_tcp" {
    depends_on = [ibm_is_security_group_rule.test_schematics_demo_sg_rule_all_in]
    group      = ibm_is_security_group.test_schematics_demo_sg.id
    direction = "inbound"
    remote = "0.0.0.0/0"
    tcp  {
        port_min = 27017
        port_max = 27017
    }
 }

resource "ibm_is_security_group_rule" "test_schematics_demo_sg_rule_all_out" {
  depends_on = [ibm_is_security_group_rule.test_schematics_demo_sg_rule_tcp]
  group      = ibm_is_security_group.test_schematics_demo_sg.id
  direction  = "outbound"
  remote     = "0.0.0.0/0"
}

data "ibm_is_image" "test_schematics_demo_image" {
  name = "ibm-ubuntu-18-04-1-minimal-amd64-2"
}

data "ibm_is_ssh_key" "test_schematics_demo_ssh_key" {
  name = "sakthi-ssh"
}

resource "ibm_is_instance" "test_schematics_demo_vsi_client" {
  depends_on = [ibm_is_security_group_rule.test_schematics_demo_sg_rule_all_out]
  name           = "test-schematics-demo-vsi-client"
  image          = data.ibm_is_image.test_schematics_demo_image.id
  profile        = "bx2-16x64"
  resource_group = data.ibm_resource_group.rg.id

  primary_network_interface {
    subnet          = ibm_is_subnet.test_schematics_demo_subnet.id
    security_groups = [ibm_is_security_group.test_schematics_demo_sg.id]
  }

  vpc  = ibm_is_vpc.test_schematics_demo_vpc.id
  zone = "us-south-1"
  keys = ["${data.ibm_is_ssh_key.test_schematics_demo_ssh_key.id}"]

  provisioner "local-exec" {
    command = "sleep 30"
  }

  #provisioner "local-exec" {
  #  command = "ansible-playbook -i '${ibm_is_floating_ip.address},' --private-key ${var.private_key_path} ../ansible/httpd.yml"
  #}

  timeouts {
    create = "10m"
    delete = "10m"
  }
}

resource "ibm_is_instance" "test_schematics_demo_vsi_server" {
  depends_on = [ibm_is_security_group_rule.test_schematics_demo_sg_rule_all_out]
  name           = "test-schematics-demo-vsi-server"
  image          = data.ibm_is_image.test_schematics_demo_image.id
  profile        = "bx2-16x64"
  resource_group = data.ibm_resource_group.rg.id

  primary_network_interface {
    subnet          = ibm_is_subnet.test_schematics_demo_subnet.id
    security_groups = [ibm_is_security_group.test_schematics_demo_sg.id]
  }

  vpc  = ibm_is_vpc.test_schematics_demo_vpc.id
  zone = "us-south-1"
  keys = ["${data.ibm_is_ssh_key.test_schematics_demo_ssh_key.id}"]

  provisioner "local-exec" {
    command = "sleep 30"
  }

  #provisioner "local-exec" {
  #  command = "ansible-playbook -i '${ibm_is_floating_ip.address},' --private-key ${var.private_key_path} ../ansible/httpd.yml"
  #}

  timeouts {
    create = "10m"
    delete = "10m"
  }
}

###
#5 Provision Private DNS for the VPC that is created in the above steps
###

resource "ibm_resource_instance" "test_schematics_demo_pdns" {
  depends_on        = [ibm_is_vpc.test_schematics_demo_vpc]
  name              = "test-schematics-demo-pdns"
  resource_group_id = data.ibm_resource_group.rg.id
  location          = "global"
  service           = "dns-svcs"
  plan              = "standard-dns"
}

resource "ibm_dns_zone" "test_schematics_demo_pdns_zone" {
  depends_on  = [ibm_resource_instance.test_schematics_demo_pdns]
  name        = "testpdns.com"
  instance_id = ibm_resource_instance.test_schematics_demo_pdns.guid
  description = "testdescription"
  label       = "testlabel"
}

resource "ibm_dns_permitted_network" "test_schematics_demo_pdns_permitted_network" {
  depends_on  = [ibm_dns_zone.test_schematics_demo_pdns_zone]
  instance_id = ibm_resource_instance.test_schematics_demo_pdns.guid
  zone_id     = ibm_dns_zone.test_schematics_demo_pdns_zone.zone_id
  vpc_crn     = ibm_is_vpc.test_schematics_demo_vpc.resource_crn
}

resource "ibm_dns_resource_record" "test_schematics_demo_pdns_record_a" {
  depends_on  = [ibm_dns_permitted_network.test_schematics_demo_pdns_permitted_network, ibm_is_instance.test_schematics_demo_vsi_server]
  instance_id = ibm_resource_instance.test_schematics_demo_pdns.guid
  zone_id     = ibm_dns_zone.test_schematics_demo_pdns_zone.zone_id
  type        = "A"
  name        = "testa"
  rdata       = ibm_is_instance.test_schematics_demo_vsi_server.primary_network_interface[0].primary_ipv4_address
  #rdata = "1.2.3.4"
  ttl         = 900
}

###
#6 Assign floating IP to the client VSI
###

resource "ibm_is_floating_ip" "test_schematics_demo_fip" {
  name   = "test-schematics-demo-fip"
  target = ibm_is_instance.test_schematics_demo_vsi_client.primary_network_interface.0.id
}

resource "ibm_is_floating_ip" "test_schematics_demo_fip_server" {
  name   = "schematics-demo-fip-server"
  target = ibm_is_instance.test_schematics_demo_vsi_server.primary_network_interface.0.id
}

###
#7 Output variables
###

output "server_private_ip" {
  value       = ibm_is_instance.test_schematics_demo_vsi_server.primary_network_interface[0].primary_ipv4_address
  description = "The private IP of the server."
}

output "client_private_ip" {
  value       = ibm_is_instance.test_schematics_demo_vsi_client.primary_network_interface[0].primary_ipv4_address
  description = "The private IP of the client."
}

output "client_floating_ip" {
  value       = ibm_is_floating_ip.test_schematics_demo_fip.address
  description = "The floating IP of the client."
}

output "server_floating_ip" {
  value       = ibm_is_floating_ip.test_schematics_demo_fip_server.address
  description = "The floating IP of the server."
}
