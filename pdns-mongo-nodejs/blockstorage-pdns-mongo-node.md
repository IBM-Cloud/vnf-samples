### Example to illustrate how a VSI can use Block Storage as data volume to store mongo db data.   

The intent of this article is to walk you through the process that are involved in setting up a virtual server instance (VSI) with block storage as data volume to store mongo db data in the IBM Cloud VPC.

After the setup, you can configure private dns in the server VSI and connect to mongo db from a client VSI that is running nodejs application. The client and server will communicate using Private DNS (p-DNS).

The example below illustrates how a Virtual Server Instance in IBM Cloud VPC can use Block Storage as data volume to store mongo db data.  

![Demo Overview](images/Demo-Overview.png)

The reader will get to know the steps to the provision below IBM Cloud services using Terraform:

- Virtual Private Cloud
- Subnet
- Two VSI's (one would act as a MongoDB server, and other as a NodeJS based client)
- Required security group rules
- Private DNS instance with required DNS records (testb.testpdns.com)

> Prerequisite:

- IBM Cloud account. 











