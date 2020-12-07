##############################################################################
# Read/validate Region
##############################################################################
data "ibm_is_region" "region" {
  name = var.region
}

data "ibm_is_zone" "zone" {
  name   = var.zone
  region = data.ibm_is_region.region.name
}

data "ibm_is_vpc" "test_cr_vpc" {
  name = var.vpc
}

# lookup SSH public keys by name
data "ibm_is_ssh_key" "my_ssh_key" {
  name = var.ssh_key
}

data "ibm_is_image" "custom_image" {
  name = "ibm-ubuntu-18-04-1-minimal-amd64-2"
}

##############################################################################
# Provider block - Alias initialized tointeract with VNFSVC account
##############################################################################
provider "ibm" {
  generation       = var.generation
  region           = var.region
  ibmcloud_timeout = 300
}

##############################################################################
# Read/validate Resource Group
##############################################################################
data "ibm_resource_group" "rg" {
  name = var.resource_group
}

resource "ibm_is_security_group" "cr_security_group" {
  name           = "cr-securitygroup"
  vpc            = data.ibm_is_vpc.test_cr_vpc.id
  resource_group = data.ibm_resource_group.rg.id
}

//security group rule to allow ssh 
resource "ibm_is_security_group_rule" "cr_sg_allow_ssh" {
  depends_on = [data.ibm_is_vpc.test_cr_vpc]
  group      = ibm_is_security_group.cr_security_group.id
  direction  = "inbound"
  remote     = "0.0.0.0/0"
  tcp {
    port_min = 22
    port_max = 22
  }
}

//security group rule to allow all for inbound
resource "ibm_is_security_group_rule" "cr_sg_rule_all" {
  depends_on = [data.ibm_is_vpc.test_cr_vpc]
  group      = ibm_is_security_group.cr_security_group.id
  direction  = "inbound"
  remote     = "0.0.0.0/0"
}

resource "ibm_is_security_group_rule" "cr_sg_rule_out_icmp" {
  depends_on = [data.ibm_is_vpc.test_cr_vpc]
  group      = ibm_is_security_group.cr_security_group.id
  direction  = "outbound"
  remote     = "0.0.0.0/0"
  icmp {
    code = 0
    type = 8
  }
}

//custom route table for subnet 1
resource "ibm_is_vpc_routing_table" "test_cr_route_table1" {
  depends_on = [data.ibm_resource_group.rg]
  name       = "test-cr-route-table11"
  vpc    = data.ibm_is_vpc.test_cr_vpc.id
}

// source subnet 1
resource "ibm_is_subnet" "test_cr_subnet1" {
  depends_on       = [ibm_is_vpc_routing_table.test_cr_route_table1]
  name             = "test-cr-subnet11"
  vpc              = data.ibm_is_vpc.test_cr_vpc.id
  zone             = var.zone
  ipv4_cidr_block  = var.subnet1_ipv4_cidr_block
  routing_table = ibm_is_vpc_routing_table.test_cr_route_table1.routing_table
  //User can configure timeouts
  timeouts {
    create = "90m"
    delete = "30m"
  }
}

//custom route table for subnet 2
resource "ibm_is_vpc_routing_table" "test_cr_route_table2" {
  depends_on = [data.ibm_resource_group.rg]
  name       = "test-cr-route-table12"
  vpc    = data.ibm_is_vpc.test_cr_vpc.id
}


// destination subnet 2
resource "ibm_is_subnet" "test_cr_subnet2" {
  depends_on       = [ibm_is_vpc_routing_table.test_cr_route_table2]
  name             = "test-cr-subnet22"
  vpc              = data.ibm_is_vpc.test_cr_vpc.id
  zone             = var.zone
  ipv4_cidr_block  = var.subnet2_ipv4_cidr_block
  routing_table = ibm_is_vpc_routing_table.test_cr_route_table2.routing_table
  //User can configure timeouts
  timeouts {
    create = "90m"
    delete = "30m"
  }
}

//custom route table for subnet 3
resource "ibm_is_vpc_routing_table" "test_cr_route_table3" {
  depends_on = [data.ibm_resource_group.rg]
  name       = "test-cr-route-table13"
  vpc     = data.ibm_is_vpc.test_cr_vpc.id
  
}

// next hop subnet 3
resource "ibm_is_subnet" "test_cr_subnet3" {
  depends_on       = [ibm_is_vpc_routing_table.test_cr_route_table3]
  name             = "test-cr-subnet33"
  vpc              = data.ibm_is_vpc.test_cr_vpc.id
  zone             = var.zone
  ipv4_cidr_block  = var.subnet3_ipv4_cidr_block
  routing_table = ibm_is_vpc_routing_table.test_cr_route_table3.routing_table
  //User can configure timeouts
  timeouts {
    create = "90m"
    delete = "30m"
  }
}

//custom route for source
resource "ibm_is_vpc_routing_table_route" "test_custom_route1" {
  depends_on     = [ibm_is_subnet.test_cr_subnet1]
  vpc         = data.ibm_is_vpc.test_cr_vpc.id
  routing_table = ibm_is_vpc_routing_table.test_cr_route_table1.routing_table
  zone           = var.zone
  name           = "custom-route-11"
  next_hop       = ibm_is_instance.vsi3.primary_network_interface[0].primary_ipv4_address
  action         = "deliver"
  destination    = ibm_is_subnet.test_cr_subnet2.ipv4_cidr_block
}

//custom route for destination
resource "ibm_is_vpc_routing_table_route" "test_custom_route2" {
  depends_on     = [ibm_is_subnet.test_cr_subnet2]
  vpc         = data.ibm_is_vpc.test_cr_vpc.id
  routing_table = ibm_is_vpc_routing_table.test_cr_route_table2.routing_table
  zone           = var.zone
  name           = "custom-route-22"
  next_hop       = ibm_is_instance.vsi3.primary_network_interface[0].primary_ipv4_address
  action         = "deliver"
  destination    = ibm_is_subnet.test_cr_subnet1.ipv4_cidr_block
}

//source vsi
resource "ibm_is_instance" "vsi1" {
  name           = "vsi1"
  image          = data.ibm_is_image.custom_image.id
  profile        = "bx2-2x8"
  resource_group = data.ibm_resource_group.rg.id

  primary_network_interface {
    subnet          = ibm_is_subnet.test_cr_subnet1.id
    security_groups = [ibm_is_security_group.cr_security_group.id]
  }

  network_interfaces {
    subnet          = ibm_is_subnet.test_cr_subnet1.id
    security_groups = [ibm_is_security_group.cr_security_group.id]
    allow_ip_spoofing = false
  }

  keys = [data.ibm_is_ssh_key.my_ssh_key.id]
  vpc  = data.ibm_is_vpc.test_cr_vpc.id
  zone = var.zone
}

//source floating ip for above VSI
resource "ibm_is_floating_ip" "vsi1_fip" {
  name   = "vsi1-fip"
  target = ibm_is_instance.vsi1.primary_network_interface[0].id
}

//destination vsi
resource "ibm_is_instance" "vsi2" {
  name           = "vsi2"
  image          = data.ibm_is_image.custom_image.id
  profile        = "bx2-2x8"
  resource_group = data.ibm_resource_group.rg.id

  primary_network_interface {
    subnet          = ibm_is_subnet.test_cr_subnet2.id
    security_groups = [ibm_is_security_group.cr_security_group.id]
  }

  vpc  = data.ibm_is_vpc.test_cr_vpc.id
  keys = [data.ibm_is_ssh_key.my_ssh_key.id]
  zone = var.zone
}

//destination floating ip for above VSI
resource "ibm_is_floating_ip" "vsi2_fip" {
  name   = "vsi2-fip"
  target = ibm_is_instance.vsi2.primary_network_interface[0].id
}

//next hop vsi
resource "ibm_is_instance" "vsi3" {
  name           = "vsi3"
  image          = data.ibm_is_image.custom_image.id
  profile        = "bx2-2x8"
  resource_group = data.ibm_resource_group.rg.id

  primary_network_interface {
    subnet            = ibm_is_subnet.test_cr_subnet3.id
    security_groups   = [ibm_is_security_group.cr_security_group.id]
    allow_ip_spoofing = true
  }

  vpc  = data.ibm_is_vpc.test_cr_vpc.id
  zone = var.zone
  keys = [data.ibm_is_ssh_key.my_ssh_key.id]
}

//next hop floating ip for above VSI
resource "ibm_is_floating_ip" "vsi3_fip" {
  name   = "vsi3-fip"
  target = ibm_is_instance.vsi3.primary_network_interface[0].id
}


data "ibm_is_vpc_default_routing_table" "table_test" {
  vpc = data.ibm_is_vpc.test_cr_vpc.id
}

output "table_test_op" {
 value = data.ibm_is_vpc_default_routing_table.table_test
}

data "ibm_is_vpc_routing_tables" "tables_test" {
  vpc = data.ibm_is_vpc.test_cr_vpc.id
}

output "tables_test_op" {
 value = data.ibm_is_vpc_routing_tables.tables_test
}

data "ibm_is_vpc_routing_table_routes" "routes_test" {
  vpc = data.ibm_is_vpc.test_cr_vpc.id
  routing_table = ibm_is_vpc_routing_table.test_cr_route_table1.routing_table
}

output "routes_test_op" {
 value = data.ibm_is_vpc_routing_table_routes.routes_test
}
