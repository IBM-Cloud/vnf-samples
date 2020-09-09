### Example to illustrate how a VSI can use Block Storage as data volume to store mongo db data.   

The intent of this article is to walk you through the process that are involved in setting up a virtual server instance (VSI) with block storage as data volume to store mongo db data in the IBM Cloud VPC. Since, the mongo db data is stored in Block Storage volume, any Virtual Server Instance can mount the data from Block storage, use it as a secondary volume and reuse the mongo db data.   

After the setup, you can configure private dns, mongo db in the server VSI and connect to mongo db from a client VSI that is running nodejs application. The client and server will communicate using Private DNS (p-DNS).

The example below illustrates how a Virtual Server Instance in IBM Cloud VPC can use Block Storage as data volume to store mongo db data.  

![Demo Overview](images/Demo-Overview.png)

The reader will get to know the steps to attach a Block Storage to a VSI and configure MongoDB:

- Create Block Storage volume. 
- Partition the volume, format the volume, and then mount it as a file system in Server VSI. 
- Install Docker and Mongodb as docker container.
- Run Mongodb container and use the mounted secondary block volume. 
- Create a database in mongo db.
- Connect to Mongodb using mongo client and test whether setup works.    

> Prerequisite:

- IBM Cloud account.   
- Follow the steps from [Example to illustrate how a nodejs application can access Mongo DB using Private DNS](https://github.com/IBM-Cloud/vnf-samples/blob/master/pdns-mongo-nodejs/README.md) and create a Server VSI, Client VSI and private dns (testb.testpdns.com)

**Create Block Storage Volume in IBM Cloud VPC** 





**References:**

Installing Docker in ubuntu
https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-16-04

How to Deploy and Manage MongoDB with Docker
https://phoenixnap.com/kb/docker-mongodb

Using your block storage data volume (CLI)
https://cloud.ibm.com/docs/vpc?topic=vpc-start-using-your-block-storage-data-volume

Steps to format and mount block storage volume 
https://github.com/hkantare/terraform-vpc-db/blob/master/playbooks/mount.yml

https://www.thachmai.info/2015/04/30/running-mongodb-container/















