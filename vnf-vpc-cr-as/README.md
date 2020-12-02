This directory contains the sample terraform code for VPC Custom Route and Anti Spoofing functionality. This is a simple use case with Source in Subnet 1, Next hop in Subnet 2 and Destination route in Subnet 3.

Use this template a Source, Destination and next hop VSI with custom routes and Aniti spoofing configured from your IBM Cloud account in IBM Cloud VPC Gen2 by using Terraform or IBM Cloud Schematics.  Schematics uses Terraform as the infrastructure-as-code engine.  With this template, you can create and manage infrastructure as a single unit as follows. For more information about how to use this template, see the IBM Cloud Schematics documentation.

The examples has a use case where source VSI and destination VSI has 2 custom routes to communicate with each other and they have next hop as VSI in another subnet where Anti spoofing is enabled. The data packets start flowing from source VSI to destination VSI through the next hop VSI where IP Forwarding is enabled and Allow IP Spoofing is enabled. 

### Source VSI in Subnet 1, Next hop VSI in Subnet 2 and Destination VSI in Subnet 3

Example:
{
	"action": "deliver",
	"destination": "10.240.67.0/24",
	"next_hop": {"address": "10.240.66.2"},
	"zone": {"name": "us-south-2"}
}

Two scenarios are there under this:

1. Next hop is a single VSI for both onward and return traffic  
![image](https://media.github.ibm.com/user/237778/files/56341b00-c2a1-11ea-8098-5b990fa2ab7e). 


2. Next hop are 2 separate VSIs, for onward and return traffic. 
![image](https://media.github.ibm.com/user/237778/files/664bfa80-c2a1-11ea-8171-2e8f190414ca). 
