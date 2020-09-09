###
#1 Setting the provider plugin for Terraform i.e. IBM
###

provider "ibm" {
  ibmcloud_api_key = "eeZfQFlBE6QAlDDph-SoJwbXXLg-AaRPt-LCKkHr-cHR"
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
  name           = var.vpc_name
  resource_group = data.ibm_resource_group.rg.id
}

###
#3 Create a Subnet for the VPC VSI resources
###

resource "ibm_is_subnet" "test_schematics_demo_subnet" {
  name            = var.subnet_name
  vpc             = ibm_is_vpc.test_schematics_demo_vpc.id
  zone            = "us-south-1"
  ipv4_cidr_block = "10.240.0.0/24"
}

###
#4 Create a Server & the Client with required the Security Group rules
###

resource "ibm_is_security_group" "test_schematics_demo_sg" {
  name           = var.sec_group_name
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
  name = var.ssh_key_name
}

resource "ibm_is_instance" "test_schematics_demo_vsi_client" {
  depends_on = [ibm_is_security_group_rule.test_schematics_demo_sg_rule_all_out]
  name           = var.vsi_client_name
  image          = data.ibm_is_image.test_schematics_demo_image.id
  profile        = "bx2-2x8"
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

resource "ibm_is_instance" "test_schematics_demo_vsi_server_1" {
  depends_on = [ibm_is_security_group_rule.test_schematics_demo_sg_rule_all_out]
  name           = var.vsi_server_name_1
  image          = data.ibm_is_image.test_schematics_demo_image.id
  profile        = "bx2-2x8"
  resource_group = data.ibm_resource_group.rg.id

  primary_network_interface {
    subnet          = ibm_is_subnet.test_schematics_demo_subnet.id
    security_groups = [ibm_is_security_group.test_schematics_demo_sg.id]
  }

  vpc  = ibm_is_vpc.test_schematics_demo_vpc.id
  zone = "us-south-1"
  keys = ["${data.ibm_is_ssh_key.test_schematics_demo_ssh_key.id}"]
  volumes = [ibm_is_volume.volume.id]

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

resource "ibm_is_volume" "volume" {
  name = var.bs_volume_name
  zone           = "us-south-1"
  iops     = 1000
  capacity = 20
  profile = "custom"
}

resource "ibm_is_instance" "test_schematics_demo_vsi_server_2" {
  depends_on = [ibm_is_security_group_rule.test_schematics_demo_sg_rule_all_out]
  name           = var.vsi_server_name_2
  image          = data.ibm_is_image.test_schematics_demo_image.id
  profile        = "bx2-2x8"
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
  name        = var.dns_zone_name
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

resource "ibm_dns_resource_record" "test_schematics_demo_pdns_record_c" {
  depends_on  = [ibm_dns_permitted_network.test_schematics_demo_pdns_permitted_network, ibm_is_instance.test_schematics_demo_vsi_server_2]
  instance_id = ibm_resource_instance.test_schematics_demo_pdns.guid
  zone_id     = ibm_dns_zone.test_schematics_demo_pdns_zone.zone_id
  type        = "A"
  name        = var.dns_record_name
  rdata       = ibm_is_instance.test_schematics_demo_vsi_server_2.primary_network_interface[0].primary_ipv4_address
  #rdata = "1.2.3.4"
  ttl         = 900
}

###
#6 Assign floating IP to the client VSI
###

resource "ibm_is_floating_ip" "test_schematics_demo_fip" {
  name   = var.fip_client_name
  target = ibm_is_instance.test_schematics_demo_vsi_client.primary_network_interface.0.id
}

resource "ibm_is_floating_ip" "test_schematics_demo_fip_server_1" {
  name   = var.fip_server_name_1
  target = ibm_is_instance.test_schematics_demo_vsi_server_1.primary_network_interface.0.id
}

resource "ibm_is_floating_ip" "test_schematics_demo_fip_server_2" {
  name   = var.fip_server_name_2
  target = ibm_is_instance.test_schematics_demo_vsi_server_2.primary_network_interface.0.id
}

###
#7 Output variables
###

output "server_1_private_ip" {
  value       = ibm_is_instance.test_schematics_demo_vsi_server_1.primary_network_interface[0].primary_ipv4_address
  description = "The private IP of the server 1."
}

output "server_2_private_ip" {
  value       = ibm_is_instance.test_schematics_demo_vsi_server_2.primary_network_interface[0].primary_ipv4_address
  description = "The private IP of the server 2."
}

output "client_private_ip" {
  value       = ibm_is_instance.test_schematics_demo_vsi_client.primary_network_interface[0].primary_ipv4_address
  description = "The private IP of the client."
}

output "client_floating_ip" {
  value       = ibm_is_floating_ip.test_schematics_demo_fip.address
  description = "The floating IP of the client."
}

output "server_1_floating_ip" {
  value       = ibm_is_floating_ip.test_schematics_demo_fip_server_1.address
  description = "The floating IP of the server 1."
}

output "server_2_floating_ip" {
  value       = ibm_is_floating_ip.test_schematics_demo_fip_server_2.address
  description = "The floating IP of the server 2."
}
