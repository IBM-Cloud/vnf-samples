# vnf-vpc-cr-as
Repo to show the VPC Custom Route and Anti Spoofing functionality 

The examples has a use case where source VSI and destination VSI has 2 custom routes to communicate with each other and they have next hop as VSI in another subnet where Anti spoofing is enabled. The data packets start flowing from source VSI to destination VSI through the next VSI where IP Forwarding is enabled. 

Source in Subnet 1, Next hop in Subnet 2 and Destination route in Subnet 3

