### Access your application using a Public Domain Name Service (DNS)

The article below illustrates an example to access your application using a public domain name service (DNS). 

Public Domain name service has advantages over accessing your application using ip address, as ip addresses are hard to remember. There are security enhancements in DNS servers. DNS servers that have been designed for security purposes. They usually ensure that attempts to hack your server environment are thwarted before entry into your machines. 

**Create a domain name in IBM Cloud**

Now, let's create a domain name in IBM Cloud using Classic Infrastructure, VPC Gen 1. 

1. Login to IBM Cloud. Select IBM Classic Infrastructure. 

2. Select Services - Domains. 

3. Register a new domain as shown below. Enter the name of the domain as **cis-terraform**.   

![Register New Domain](images/cis-terraform-domain.png)

4. Click **Check Availability**. Only when the domain is **Available**, try to create domain.    

5. Click **Continue**. Enter the details to complete registration. Enter your company address and provide your email address.   

![Complete registration](images/complete-registration.png)

6. Check your email inbox. You will receive mail with a link to verify. Sometimes, it is auto verified. Once, it is verified, you will find the status as **verified** under column **Verified** as shown below under **Services** - **Domains** - **cis-terraform** domain.   

![domain verified](images/cis-terraform-domain-verified.png)


**Create Internet Services in IBM Cloud **


1. Click on **Catalog** tab at the top menu bar in IBM Cloud. Search for **Internet Services**. Select **Internet Services**. Enter a Service name and select a resource group. Select **Enterprise Usage** plan. Click **Create**. 

2. Click **Add Domain** and enter the domain name as **cis-terraform.com**. Click **Next**. Skip DNS Records. Click **Next** in **Domain Management**. It will display 2 **Name Servers**.  Copy the domain name servers.    

![add domain](images/InternetServices_AddDomain.png)

3. Once the domain name is added, you will get a screen as shown below. Note the status should change from **Pending** to **Active** as shown below.     

![domain added](images/Internet_Services_Add_Domain.png)

4. When the status of domain is **Active**, click **DNS Records** and add a record of type **A** with name as **name** and **IP address** pointing to your nodejs application floating ip address. **Note**: Here, the DNS record added is **A record**. It is by default, listening in port 80 for http protocol and port 443 for https protocol. So, the nodejs application should be running in port number 80. Please see the screen shot below:  

![A record added](images/DNS_Record_A.png)

5. Now, try to access the application as name of **A record . domain name** as shown below:  

![application dns](images/dns_nodejs.png)






