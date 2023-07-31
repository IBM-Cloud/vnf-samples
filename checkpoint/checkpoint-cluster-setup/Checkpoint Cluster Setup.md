Login to IBM Cloud Catalog and search for “Check Point CloudGuard IaaS Security Cluster”

 ![Alt_Text](images/Picture1.png?raw=true "Optional Title")

Now provide the name, resource group and location.

 ![Alt_Text](images/Picture2.png?raw=true "Optional Title")

Fill the below details as required 

 ![Alt_Text](images/Picture3.png?raw=true "Optional Title")

After that click on Install

 ![Alt_Text](images/Picture4.png?raw=true "Optional Title")

Now Terraform jobs will start. It will take 10-15 mins to configure the cluster.

 ![Alt_Text](images/Picture5.png?raw=true "Optional Title")

After the job runs successfully, click on the Load Balancer from VPC Infrastructure.

 ![Alt_Text](images/Picture6.png?raw=true "Optional Title")

Check that your load balancer is active.

 ![Alt_Text](images/Picture7.png?raw=true "Optional Title")

Click on the load balancer name and check the health status of the members.

 ![Alt_Text](images/Picture8.png?raw=true "Optional Title")

Now click on the Virtual Sever Instances and find your instances to be active and also check the Floating IP attached with both the instances.

 ![Alt_Text](images/Picture9.png?raw=true "Optional Title")

Setting Admin Password for Cluster Gateways 

For security purposes we will need to log into both Check Point gateways with our SSH-key. Here we will set Admin account password allowing us to login in to the web portal to run the First-Time-Wizard configuration utility. To login use the below command with Floating-IP of checkpoint-gateway-instance.

**ssh admin@< floating-ip >**

1\. At the prompt type set user admin password.

2\. Enter your password and store it appropriately.

3\. Type save config.

4\. Type exit to close session.


SmartConsole

1. Connect with SmartConsole to the Management Server.
2. From the left navigation panel, click Gateways & Servers.
3. Create a new Cluster object in one of these ways:
   
   a. From the top toolbar, click New () > Cluster > Cluster.
   
   b. In the top left corner, click Objects menu > More object types > Network Object > Gateways and Servers > Cluster > New Cluster.

   c. In the top right corner, click Objects Pane > New > More > Network Object > Gateways and Servers > Cluster > Cluster.

Note: We followed Step 3(a).

 ![Alt_Text](images/Picture10.png?raw=true "Optional Title")

4. In the Check Point Security Gateway Cluster Creation window, you must click Classic Mode.

  ![Alt_Text](images/Picture11.png?raw=true "Optional Title")

5. From the left tree, click General Properties.

   a. In the IPv4 Address field, you must enter the 0.0.0.0 address.

 ![Alt_Text](images/Picture12.png?raw=true "Optional Title")
   
   b. On the Network Security tab, you must clear IPsec VPN.

 ![Alt_Text](images/Picture13.png?raw=true "Optional Title")

6. From the left tree, click Cluster Members.

   a. Click Add > New Cluster Member.

 ![Alt_Text](images/Picture14.png?raw=true "Optional Title")


   The Cluster Member Properties window opens.

   b. In the Name field, enter the applicable name for the first Cluster Member object.
   c. Configure the main physical IP address(es) for this Cluster Member object.

   In the IPv4 Address and IPv6 Address fields, configure the same IPv4 and IPv6 addresses that you configured on the Management Connection page of the Cluster Member's First Time Configuration Wizard.

   Make sure the Security Management Server or Multi-Domain Server can connect to these IP 	addresses.

   d. Click Communication.
   
   e. In the One-time password and confirm one-time password fields, enter the same Activation Key you entered during the Cluster Member's First Time Configuration Wizard.
   
   f. Click Initialize.
   
   g. Click Close.
   
   h. Click OK.

Repeat Steps a-h to add the next Cluster Member.


 ![Alt_Text](images/Picture15.png?raw=true "Optional Title")

 ![Alt_Text](images/Picture16.png?raw=true "Optional Title")

 ![Alt_Text](images/Picture17.png?raw=true "Optional Title")

7. From the left tree, click ClusterXL and VRRP.
   
   a. In the Select the cluster mode and configuration section, select Active-Active.

   b. In the Tracking section, select the applicable option.

   c. Optional: Select Use State Synchronization.

   This configures the Cluster Members to synchronize the information about the connections they inspect.

- Best Practice - Enable this setting to prevent connection drops after a cluster failover.

   d. Optional: Select Start synchronizing [  ] seconds after connection initiation and enter the applicable value.

   This option is available only for clusters R80.20 and higher.

   To prevent the synchronization of short-lived connections (which decreases the cluster performance), you can configure the Cluster Members to start the synchronization of all connections a number of seconds after they start.

   Range: 2 - 60 seconds

   Default: 3 seconds

Notes : This setting in the cluster object applies to all connections that pass through the cluster. You can override this global cluster synchronization delay in the properties of applicable services. The greater this value, the fewer short-lived connections the Cluster Members have to synchronize. The connections that the Cluster Members did not synchronize, do not survive a cluster failover.

- Best Practice - Enable and configure this setting to increase the cluster performance.

![Alt_Text](images/Picture18.png?raw=true "Optional Title")

8. Click OK to update the cluster object properties with the new cluster mode.

9. Open the cluster object and continue the configuration.

10. From the left tree, click Network Management.

 ![Alt_Text](images/Picture19.png?raw=true "Optional Title")
 
   a. From the top, click the Get Interfaces > Get Interfaces With Topology.

 ![Alt_Text](images/Picture20.png?raw=true "Optional Title")

- Important - On all Cluster Members in Active-Active mode, names of interfaces that belong to the same "side" must be identical (Known Limitation PMTR-70256).

   b. Select each interface and click Edit.
  
   c. From the left tree, click the General page.

 ![Alt_Text](images/Picture21.png?raw=true "Optional Title")
 
   d. In the General section, in the Network Type field, select the applicable type:
- For cluster traffic interfaces, select Cluster.

In the IPv4 field, the dummy IP address 0.0.0.0 / 24 is configured automatically.

Note - SmartConsole requires an IP address configured for each interface. Cluster Members do not get and do not use this IP address.

- For cluster synchronization interfaces, select Sync.

Notes: Check Point cluster supports only one synchronization network. If redundancy is required, configure a Bond interface. In the Network Type field, it is not supported to select "Cluster+Sync" (Known Limitation PMTR-70259) when you deploy a cluster in a cloud (for example: AWS, Azure).

- For interfaces that do not pass the traffic between the connected networks, select Private.

e. In the Member IPs section, make sure the IPv4 address and its Net Mask are correct on each Cluster Member.

f. In the Topology section:

Make sure the settings are correct in the Leads To and Security Zone fields.

Only these options are supported on cluster interfaces 

Override > Network defined by routes (this is the default).

Override > Specific > select the applicable Network object or Network Group object.

11. Click OK.

12. Publish the SmartConsole session.

 ![Alt_Text](images/Picture22.png?raw=true "Optional Title")
 
13. Configure and install the applicable Access Control Policy and Threat Prevention Policy.

 ![Alt_Text](images/Picture23.png?raw=true "Optional Title")
