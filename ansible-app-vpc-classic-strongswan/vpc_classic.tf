terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
    }
  }
}

variable "region" {
  default     = "us-south"
  description = "The VPC Region that you want your VPC, Transit Gateway and PDNS to be provisioned it. To list available regions, run `ibmcloud is regions`."
}

variable "generation" {
  default     = 2
  description = "The VPC Generation to target. Valid values are 2 or 1."
}

variable "address1" {
  default     = ""
  description = "The first ip address of the ALB Service"
}

variable "address2" {
  default     = ""
  description = "The second ip address of the ALB Service"
}

variable "address3" {
  default     = ""
  description = "The third ip address of the ALB Service"
}

variable "peer_address" {
  default     = "169.38.71.124"
  description = "Peer VPN gateway address"
}

variable "vpc_crn" {
  default     = ""
  description = "crn of VPC Gen2 to be connected with Transit Gateway"
}


##############################################################################
# Read/validate Region
##############################################################################
data "ibm_is_region" "region" {
  name = var.region
}

#data "ibm_is_zone" "zone" {
#  name = "us-south-1"
#  region = data.ibm_is_region.region.name
#}

##############################################################################
# Provider block - Alias initialized tointeract with VNF Experiment account
##############################################################################
provider "ibm" {
  ibmcloud_api_key      = ""
  generation            = var.generation
  region                = var.region
  ibmcloud_timeout      = 300
}


################################
# Transit Gateway Provisioning
################################

data "ibm_resource_group" "group" {
  name="Default"
}

variable "client_vpn_gateway_subnet" {
  default     = "subnet-demo-think-peer-1"
  description = "Name of the Subnet ipv4 cidr block of Client VPN Gateway."
}

variable "client_subnet" {
  default     = "192.168.0.0/24"
  description = "Local CIDR"
}


variable "server_subnet" {
  default     = "10.163.49.64/26"
  description = "Peer CIDR"
}


data "ibm_is_subnet" "client_vpn_subnet" {
  name = var.client_vpn_gateway_subnet
}
/*
resource "ibm_is_vpn_gateway" "VPNClientGateway" {
  name   = "demo-think-classic-vpc-vpn"
  subnet = data.ibm_is_subnet.client_vpn_subnet.id
  resource_group = data.ibm_resource_group.group.id
  mode = "policy"
  provisioner "local-exec" {
    command = "sleep 180"
  }
}
*/

data "ibm_is_vpn_gateway" "VPNClientGateway" {
  vpn_gateway_name = "demo-think-peer-vpn-test"
}

/*
resource "ibm_is_ike_policy" "example" {
  name                     = "test-ike"
  authentication_algorithm = "md5"
  // Available options are md5, sha1, sha256, sha512, sha384.
  encryption_algorithm     = "triple_des"
  dh_group                 = 2
  ike_version              = 1

  // ike: aes256-aes192-aes128-sha512-sha384-sha256-modp2048s256-modp2048s224-modp1024s160-ecp521-ecp384-ecp256-modp8192-modp6144-modp4096-modp3072-modp2048-x25519!
}

resource "ibm_is_vpn_gateway_connection" "VPNGatewayConnection2" {
  name           = "vpnconn2"
  vpn_gateway    = ibm_is_vpn_gateway.VPNGateway2.id
  peer_address   = ibm_is_vpn_gateway.VPNGateway2.public_ip_address
  preshared_key  = "VPNDemoPassword"
  local_cidrs    = [ibm_is_subnet.subnet2.ipv4_cidr_block]
  peer_cidrs     = [ibm_is_subnet.subnet1.ipv4_cidr_block]
  admin_state_up = true
  ike_policy     = ibm_is_ike_policy.example.id
}
*/

resource "ibm_is_vpn_gateway_connection" "VPNClientGateway_Conn1" {
  name = "demo-think-classic-vpc-vpn-gw-conn1"
  vpn_gateway = data.ibm_is_vpn_gateway.VPNClientGateway.id
  peer_address= var.peer_address
  local_cidrs = [var.client_subnet] 
  peer_cidrs = [var.server_subnet] 
  preshared_key = "secret"
  admin_state_up = true
}
