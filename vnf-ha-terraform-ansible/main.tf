terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
    }
  }
}

data "ibm_is_region" "region" {
  name = var.region
}

# create VSI in the subnet of HA pair
data "ibm_is_subnet" "vnf_subnet"{
   identifier = "${var.failover_function_subnet_id}"
}

# lookup SSH public keys by name
data "ibm_is_ssh_key" "ssh_key" {
  name = var.ssh_key
}

data "ibm_is_image" "custom_image" {
  name = "ibm-ubuntu-20-04-5-minimal-amd64-1"
}

##############################################################################
# Provider block - Alias initialized tointeract with VNFSVC account
##############################################################################
provider "ibm" {
  ibmcloud_api_key = var.IC_API_KEY
  generation       = var.generation
  region           = var.region
  ibmcloud_timeout = 300
}

##############################################################################
# Read/validate Resource Group
##############################################################################

resource "ibm_is_security_group" "ubuntu_vsi_sg" {
  name           = "ubuntu-vsi-sg-2"
  vpc            = data.ibm_is_subnet.vnf_subnet.vpc
  resource_group = data.ibm_is_subnet.vnf_subnet.resource_group
}

//security group rule to allow ssh
resource "ibm_is_security_group_rule" "ubuntu_sg_allow_ssh" {
  group     = ibm_is_security_group.ubuntu_vsi_sg.id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  tcp {
    port_min = 22
    port_max = 22
  }
}

resource "ibm_is_security_group_rule" "ubuntu_sg_rule_tcp" {
  depends_on = [ibm_is_security_group_rule.ubuntu_sg_allow_ssh]
  group      = ibm_is_security_group.ubuntu_vsi_sg.id
  direction  = "inbound"
  remote     = var.vnf_mgmt_ipv4_cidr_block
  // remote = "0.0.0.0/0"
  tcp {
    port_min = 3000
    port_max = 3000
  }
}

resource "ibm_is_security_group_rule" "ubuntu_sg_rule_out_icmp" {
  depends_on = [ibm_is_security_group_rule.ubuntu_sg_rule_tcp]
  group      = ibm_is_security_group.ubuntu_vsi_sg.id
  direction  = "outbound"
  remote     = "0.0.0.0/0"
  icmp {
    code = 0
    type = 8
  }
}

resource "ibm_is_security_group_rule" "ubuntu_sg_rule_all_out" {
  depends_on = [ibm_is_security_group_rule.ubuntu_sg_rule_out_icmp]
  group      = ibm_is_security_group.ubuntu_vsi_sg.id
  direction  = "outbound"
  remote     = "0.0.0.0/0"
}

//source vsi
resource "ibm_is_instance" "ubuntu_vsi" {
  depends_on     = [ibm_is_security_group_rule.ubuntu_sg_rule_all_out]
  name           = "ubuntu-ha-vsi-2"
  image          = data.ibm_is_image.custom_image.id
  profile        = "bx2-2x8"
  resource_group = data.ibm_is_subnet.vnf_subnet.resource_group

  primary_network_interface {
    subnet          = var.failover_function_subnet_id
    security_groups = [ibm_is_security_group.ubuntu_vsi_sg.id]
  }

  keys = [data.ibm_is_ssh_key.ssh_key.id]
  vpc  = data.ibm_is_subnet.vnf_subnet.vpc
  zone = data.ibm_is_subnet.vnf_subnet.zone
}

//floating ip for above VSI
resource "ibm_is_floating_ip" "ubuntu_vsi_fip" {
  name   = "ubuntu-vsi-fip-2"
  target = ibm_is_instance.ubuntu_vsi.primary_network_interface[0].id
}

# ---------------------------------------------------------------------------------------------------------------------
# Provision the server using ansible-provisioner
# ---------------------------------------------------------------------------------------------------------------------

/*
resource "null_resource" "ubuntu_ansible_provisioner" {
  depends_on = [ibm_is_floating_ip.ubuntu_vsi_fip]

  triggers = {
    public_ip = ibm_is_floating_ip.ubuntu_vsi_fip.address
  }

  connection {
    host = ibm_is_floating_ip.ubuntu_vsi_fip.address
    user = "root"  
    private_key = var.private_ssh_key
  }

  
  provisioner "local-exec"  {
    plays {
      playbook {
        file_path = "script/install.yaml"
      }
      verbose = true
       extra_vars = {
        vpcid = data.ibm_is_subnet.vnf_subnet.vpc
        vpcurl = var.rias_api_url
        zone = data.ibm_is_subnet.vnf_subnet.zone
        apikey = var.apikey
        mgmtip1 = var.mgmt_ip1
        extip1 = var.ext_ip1
        mgmtip2 = var.mgmt_ip2
        extip2 = var.ext_ip2
        ipaddress = ibm_is_instance.ubuntu_vsi.primary_network_interface[0].primary_ipv4_address 
        ha1pwd = var.ha_password1
        ha2pwd = var.ha_password2
      }
    }

    ansible_ssh_settings {
      insecure_no_strict_host_key_checking = true
      connect_timeout_seconds              = 60
    }

  }
}
*/

resource "null_resource" "copy_file_provisioner" {
  depends_on = [ibm_is_floating_ip.ubuntu_vsi_fip]
  
  #Copies the string in content into ./hosts
  provisioner "local-exec" {
   command = "echo ${ibm_is_floating_ip.ubuntu_vsi_fip.address} ansible_ssh_host=${ibm_is_floating_ip.ubuntu_vsi_fip.address} ansible_connection=ssh ansible_ssh_user=root ansible_ssh_common_args=\"'-o StrictHostKeyChecking=no'\" > hosts_file.txt"
   }

}
  
resource "null_resource" "ubuntu_ansible_provisioner" {
  depends_on = [null_resource.copy_file_provisioner]
  
  connection {
	type = "ssh"  
    host = ibm_is_floating_ip.ubuntu_vsi_fip.address
    user = "root"
    private_key = file("./txt.txt")
  }

  provisioner "local-exec"  {
	  connection {
		type = "ssh"  
	    host = ibm_is_floating_ip.ubuntu_vsi_fip.address
	    user = "root"
	    private_key = file("./txt.txt")
	  }  
    command = "chmod 0600 txt.txt; ansible-playbook script/install.yaml -i hosts_file.txt --fork 1 --user root --private-key ./txt.txt -e 'vpcid=${data.ibm_is_subnet.vnf_subnet.vpc} vpcurl=${var.rias_api_url} zone=${data.ibm_is_subnet.vnf_subnet.zone} apikey=${var.apikey} mgmtip1=${var.mgmt_ip1} extip1=${var.ext_ip1} mgmtip2=${var.mgmt_ip2} extip2=${var.ext_ip2} ipaddress=${ibm_is_instance.ubuntu_vsi.primary_network_interface[0].primary_ipv4_address} ha1pwd=${var.ha_password1} ha2pwd=${var.ha_password2}'"
  }
}
