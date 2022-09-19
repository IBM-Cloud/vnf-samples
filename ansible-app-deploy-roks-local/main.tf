terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
    }
  }
}

variable "region" {
  default     = "us-south"
  description = "The VPC Region that you want your VPC, networks and the F5 virtual server to be provisioned in. To list available regions, run `ibmcloud is regions`."
}

variable "generation" {
  default     = 2
  description = "The VPC Generation to target. Valid values are 2 or 1."
}

##############################################################################
# Read/validate Region
##############################################################################
data "ibm_is_region" "region" {
  name = var.region
}

data "ibm_is_zone" "zone" {
  name = "us-south-1"
  region = data.ibm_is_region.region.name
}

##############################################################################
# Provider block - Alias initialized tointeract with VNF Experiment account
##############################################################################
provider "ibm" {
  ibmcloud_api_key = ""
  generation            = var.generation
  region                = var.region
  ibmcloud_timeout      = 300
}

##############################################################################
# Read/validate Resource Group
##############################################################################
data "ibm_resource_group" "group" {
  name="Default"
}


data "ibm_is_lbs" "app_lb_service"{
}

output "lb_private" {
  value = data.ibm_is_lbs.app_lb_service
  description = "The list of load balancer services running in IBM Cloud VPC."
}


variable "client_vpn_gateway_subnet" {
  default     = "subnet-demo-think-peer-1"
  description = "Name of the Subnet ipv4 cidr block of Client VPN Gateway."
}

variable "server_vpn_gateway_subnet1" {
  default     = "sn-20220715-01"
  description = "Name of subnet 1 ipv4 cidr block of Server VPN Gateway"
}

variable "server_vpn_gateway_subnet2" {
  default     = "sn-20220715-03"
  description = "Name of subnet 2 ipv4 cidr block of Server VPN Gateway"
}

data "ibm_is_subnet" "client_subnet" {
  name = var.client_vpn_gateway_subnet
}

data "ibm_is_subnet" "server_subnet1" {
  name = var.server_vpn_gateway_subnet1
}

data "ibm_is_subnet" "server_subnet2" {
  name = var.server_vpn_gateway_subnet2
}

output "subnet_client" {
  value = data.ibm_is_subnet.client_subnet
  description = "Client subnet."
}

output "subnet_server1" {
  value = data.ibm_is_subnet.server_subnet1
  description = "Server subnet 1"
}


output "subnet_server2" {
  value = data.ibm_is_subnet.server_subnet2
  description = "Server subnet 2"
}


resource "ibm_is_vpn_gateway" "VPNClientGateway" {
  name   = "demo-think-peer-vpn"
  subnet = data.ibm_is_subnet.client_subnet.id
  resource_group = data.ibm_resource_group.group.id
  mode = "policy"
  provisioner "local-exec" {
    command = "sleep 180"
  }
}

resource "ibm_is_vpn_gateway" "VPNPeerGateway1" {
  name   = "think-demo-rok2-vpn-gw"
  subnet = data.ibm_is_subnet.server_subnet1.id
  resource_group = data.ibm_resource_group.group.id
  mode = "policy"
  provisioner "local-exec" {
    command = "sleep 180"
  }
}

resource "ibm_is_vpn_gateway" "VPNPeerGateway2" {
  name   = "think-demo-rok2-vpn-gw-2"
  subnet = data.ibm_is_subnet.server_subnet2.id
  resource_group = data.ibm_resource_group.group.id
  mode = "policy"
  provisioner "local-exec" {
    command = "sleep 180"
  }
}

resource "ibm_is_vpn_gateway_connection" "VPNClientGateway_Conn1" {
  name = "demo-think-peer-vpn-gw-conn1"
  vpn_gateway = ibm_is_vpn_gateway.VPNClientGateway.id
  peer_address = ibm_is_vpn_gateway.VPNClientGateway.public_ip_address == "0.0.0.0" ? ibm_is_vpn_gateway.VPNClientGateway.public_ip_address2 : ibm_is_vpn_gateway.VPNClientGateway.public_ip_address
  local_cidrs = [data.ibm_is_subnet.client_subnet.ipv4_cidr_block] 
  peer_cidrs = [data.ibm_is_subnet.server_subnet1.ipv4_cidr_block] 
  preshared_key = "secret"
  admin_state_up = true
  depends_on = [ibm_is_vpn_gateway.VPNPeerGateway1]
}

resource "ibm_is_vpn_gateway_connection" "VPNClientGateway_Conn2" {
  name = "demo-think-peer-vpn-gw-conn2"
  vpn_gateway = ibm_is_vpn_gateway.VPNClientGateway.id
  peer_address = ibm_is_vpn_gateway.VPNPeerGateway2.public_ip_address
  local_cidrs = [data.ibm_is_subnet.client_subnet.ipv4_cidr_block]
  peer_cidrs = [data.ibm_is_subnet.server_subnet2.ipv4_cidr_block]
  preshared_key = "secret"
  admin_state_up = true
  depends_on = [ibm_is_vpn_gateway.VPNPeerGateway2]
}

resource "ibm_is_vpn_gateway_connection" "VPNPeerGateway1_Conn1" {
  name = "think-demo-rok2-vpn-gw-conn1"
  vpn_gateway = ibm_is_vpn_gateway.VPNPeerGateway1.id
  peer_address = ibm_is_vpn_gateway.VPNClientGateway.public_ip_address == "0.0.0.0" ? ibm_is_vpn_gateway.VPNClientGateway.public_ip_address2 : ibm_is_vpn_gateway.VPNClientGateway.public_ip_address
  local_cidrs = [data.ibm_is_subnet.server_subnet1.ipv4_cidr_block]
  peer_cidrs = [data.ibm_is_subnet.client_subnet.ipv4_cidr_block]
  preshared_key = "secret"
  admin_state_up = true
  depends_on = [ibm_is_vpn_gateway.VPNClientGateway]
}

resource "ibm_is_vpn_gateway_connection" "VPNPeerGateway2_Conn1" {
  name = "think-demo-rok2-vpn-gw-2-conn1"
  vpn_gateway = ibm_is_vpn_gateway.VPNPeerGateway2.id
  peer_address = ibm_is_vpn_gateway.VPNClientGateway.public_ip_address == "0.0.0.0" ? ibm_is_vpn_gateway.VPNClientGateway.public_ip_address2 : ibm_is_vpn_gateway.VPNClientGateway.public_ip_address
  local_cidrs = [data.ibm_is_subnet.server_subnet2.ipv4_cidr_block]
  peer_cidrs = [data.ibm_is_subnet.client_subnet.ipv4_cidr_block]
  preshared_key = "secret"
  admin_state_up = true
  depends_on = [ibm_is_vpn_gateway.VPNClientGateway]
}

output "client_gw" {
  value = ibm_is_vpn_gateway.VPNClientGateway
  description = "Client VPN gateway"
}

output "server_gw1" {
  value = ibm_is_vpn_gateway.VPNPeerGateway1
  description = "Peer VPN gateway 1"
}

output "server_gw2" {
  value = ibm_is_vpn_gateway.VPNPeerGateway2
  description = "Peer VPN gateway 2"
}
