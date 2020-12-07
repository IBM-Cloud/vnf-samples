# Custom Route and Anti-spoofing Sample

This directory contains the sample terraform code for VPC Custom Route and Anti Spoofing functionality. This is a simple use case with Source in Subnet 1, Next hop in Subnet 3 and Destination route in Subnet 2.

Use this template to create a Source, Destination and next hop VSI with custom routes and Aniti spoofing configured from your IBM Cloud account in IBM Cloud VPC Gen2 by using Terraform or IBM Cloud Schematics. Schematics uses Terraform as the infrastructure-as-code engine. With this template, you can create and manage infrastructure as a single unit as follows. For more information about how to use this template, see the IBM Cloud Schematics documentation.

The example provided has a use case where source VSI and destination VSI has 2 custom routes to communicate with each other and they have next hop as VSI in another subnet where Anti spoofing is enabled. The data packets start flowing from source VSI to destination VSI through the next hop VSI where Allow IP Spoofing is enabled (IP Forwarding is enabled in ubuntu VSI). If Allow IP Spoofing is turned OFF, the next hop VSI will not send the data packets to destination VSI.  

### Source VSI1 in Subnet 1, Next hop VSI3 in Subnet 3 and Destination VSI2 in Subnet 2

Example:

```
Route R1:
{   
	"action" = "deliver",  
	"destination" = ibm_is_subnet.test_cr_subnet2.ipv4_cidr_block,   
	"next_hop" = ibm_is_instance.vsi3.primary_network_interface[0].primary_ipv4_address,  
	"zone" = "us-south-1" 
}  

Route R2:
{   
	"action" = "deliver",  
	"destination" = ibm_is_subnet.test_cr_subnet1.ipv4_cidr_block,   
	"next_hop" = ibm_is_instance.vsi3.primary_network_interface[0].primary_ipv4_address,  
	"zone" = "us-south-1" 
}
```
This is the scenario:

Next hop is a single VSI for both onward and return traffic  
![image](https://github.com/IBM-Cloud/vnf-samples/blob/master/images/cr_as_tf.jpg). 

In the next hop VSI, Allow IP Spoofing has to be enabled, so that the next hop VSI allows the traffic to flow from Source VSI to the destination VSI.

Once, the resources are provsioned, Login to each of the VSI and try to ping from source VSI to destination VSI and destination VSI to source VSI. Also, enable TCP dumps and view the logs in next hop VSI. This is the simplest use case for Custom routes and Anti Spoofing functionality. 

### Notes

1. Multiple subnets can be associated with a single routing table. 

	For example 
	```
	resource "ibm_is_subnet" "test_cr_subnet1" {
  		...
  		routing_table = ibm_is_vpc_routing_table.test_cr_route_table1.routing_table 
	}
	
	resource "ibm_is_subnet" "test_cr_subnet2" {
  		...
  		routing_table = ibm_is_vpc_routing_table.test_cr_route_table1.routing_table
		//Above routing table is the same as in test_cr_subnet1
	}
	```
	
	(However in the sample code we have shown different routing tables being associated with different subnets.)
	
2. Routing table with any ingress parameters set as true should not be associated with any subnets.

### Useful Information for Custom Routes and Anti-Spoofing VPC Gen 2 Offering:  
User Docs Custom Routes:  https://cloud.ibm.com/docs/vpc?topic=vpc-about-custom-routes   
User Docs Customer Adjustable Anti-Spoofing: https://cloud.ibm.com/docs/vpc?topic=vpc-ip-spoofing-about   
API Doc:  https://cloud.ibm.com/apidocs/vpc   
CLI Doc:  https://cloud.ibm.com/docs/vpc?topic=vpc-infrastructure-cli-plugin-vpc-reference#custom-routes-section  


