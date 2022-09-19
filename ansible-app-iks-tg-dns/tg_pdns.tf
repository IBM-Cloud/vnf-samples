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

variable "vpc_crn" {
  default     = ""
  description = "crn of VPC Gen2 to be connected with Transit Gateway"
}

variable "dns_instance_id"{
  default = ""
  description = "GUID of DNS Service"
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

resource "ibm_tg_gateway" "tdemo_tg_gw"{
name           = "tdemo-classic-vpc-tg-gw"
location       = var.region
global         = false
resource_group = data.ibm_resource_group.group.id
}

resource "ibm_tg_connection" "tdemo_ibm_tg_connection_1" {
  gateway      = ibm_tg_gateway.tdemo_tg_gw.id
  network_type = "vpc"
  name         = "think-demo-tgw-conn-1"
  #network_id   = ibm_is_vpc.test_tg_vpc.resource_crn
  network_id   = var.vpc_crn
}

resource "ibm_tg_connection" "test_ibm_tg_connection_2" {
  gateway      = ibm_tg_gateway.tdemo_tg_gw.id
  network_type = "classic"
  name         = "think-demo-tgw-conn-2"
}


####################
# PDNS Provisioning
####################


resource "ibm_dns_zone" "tdemo-pdns-1-zone" {
    name = "myapp.com"
    instance_id = var.dns_instance_id
    description = "PDNS for storing NLB IPs of think demo"
    label = "think_demo_pdns_zone"
}


resource "ibm_dns_permitted_network" "tdemo-test-pdns-permitted-network-nw" {
    #instance_id = ibm_resource_instance.test-pdns-instance.guid
    instance_id = var.dns_instance_id
    zone_id = ibm_dns_zone.tdemo-pdns-1-zone.zone_id
    vpc_crn = var.vpc_crn
    #vpc_crn = ibm_is_vpc.test_pdns_vpc.crn
    type = "vpc"
}

resource "ibm_dns_glb_pool" "tdemo-test-pdns-pool-nw" {
  depends_on                = [ibm_dns_zone.tdemo-pdns-1-zone]
  name                      = "think-demo-glb-pool"
  instance_id               = var.dns_instance_id
  description               = "Think demo test pool"
  enabled                   = true
  healthy_origins_threshold = 1
  origins {
    name        = "origin-1"
    address     = var.address1
    enabled     = true
    description = "origin pool member 1"
  }
  origins {
    name        = "origin-2"
    address     = var.address2
    enabled     = true
    description = "origin pool member 2"

  }
  origins {
    name        = "origin-3"
    address     = var.address3
    enabled     = true
    description = "origin pool member 3"

  }
}

resource "ibm_dns_glb" "test_pdns_glb" {
  depends_on    = [ibm_dns_glb_pool.tdemo-test-pdns-pool-nw]
  name          = "think"
  instance_id   = var.dns_instance_id
  zone_id       = ibm_dns_zone.tdemo-pdns-1-zone.zone_id
  description   = "GLB for think demo"
  ttl           = 120
  enabled       = true
  fallback_pool = ibm_dns_glb_pool.tdemo-test-pdns-pool-nw.pool_id
  default_pools = [ibm_dns_glb_pool.tdemo-test-pdns-pool-nw.pool_id]
}

  









  
