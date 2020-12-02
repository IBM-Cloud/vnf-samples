This directory contains the sample terraform code for VPC Custom Route and Anti Spoofing functionality. This is a simple use case with Source in Subnet 1, Next hop in Subnet 2 and Destination route in Subnet 3.

Use this template to create a Source, Destination and next hop VSI with custom routes and Aniti spoofing configured from your IBM Cloud account in IBM Cloud VPC Gen2 by using Terraform or IBM Cloud Schematics. Schematics uses Terraform as the infrastructure-as-code engine. With this template, you can create and manage infrastructure as a single unit as follows. For more information about how to use this template, see the IBM Cloud Schematics documentation.

The examples has a use case where source VSI and destination VSI has 2 custom routes to communicate with each other and they have next hop as VSI in another subnet where Anti spoofing is enabled. The data packets start flowing from source VSI to destination VSI through the next hop VSI where Allow IP Spoofing is enabled (IP Forwarding is enabled in ubuntu VSI). If Allow IP Spoofing is turned OFF, the next hop VSI will not send the data packets to destination VSI.  

### Source VSI1 in Subnet 1, Next hop VSI3 in Subnet 2 and Destination VSI2 in Subnet 3

Example:  
{   
	"action" = "deliver",  
	"destination" = ibm_is_subnet.test_cr_subnet2.ipv4_cidr_block,   
	"next_hop" = ibm_is_instance.vsi3.primary_network_interface[0].primary_ipv4_address,  
	"zone" = "us-south-1" 
}   

This is the scenario:

Next hop is a single VSI for both onward and return traffic  
![image](https://media.github.ibm.com/user/237778/files/56341b00-c2a1-11ea-8098-5b990fa2ab7e). 

In the next hop VSI, Allow IP Spoofing has to be enabled, so that the next hop VSI allows the traffic to flow from Source VSI to the destination VSI.

Once, the resources are provsioned, Login to each of the VSI and try to ping from source VSI to destination VSI and destination VSI to source VSI. Also, enable TCP dumps and view the logs in next hop VSI. This is the simplest use case for Custom routes and Anti Spoofing functionality. 
