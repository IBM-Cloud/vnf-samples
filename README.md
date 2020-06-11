# vnf-samples
vnf-samples

# Red hat Linux Virtual Server for Virtual Private Cloud using Custom Image
  
Use this template to create RHEL 7 virtual server using custom image from your IBM Cloud account in IBM Cloud [VPC Gen2](https://cloud.ibm.com/vpc-ext/overview) by using Terraform or IBM Cloud Schematics.  Schematics uses Terraform as the infrastructure-as-code engine.  With this template, you can create and manage infrastructure as a single unit as follows. For more information about how to use this template, see the IBM Cloud [Schematics documentation](https://cloud.ibm.com/docs/schematics).


# IBM Cloud IaaS Support
You're provided free technical support through the IBM Cloud™ community and Stack Overflow, which you can access from the Support Center. The level of support that you select determines the severity that you can assign to support cases and your level of access to the tools available in the Support Center. Choose a Basic, Advanced, or Premium support plan to customize your IBM Cloud™ support experience for your business needs.

Learn more: https://www.ibm.com/cloud/support

## Prerequisites

- Have access to [Gen 2 VPC](https://cloud.ibm.com/vpc-ext/network/vpcs).
- The given VPC must have at least one subnet IP address unassigned - the RHEL 7 VSI will be assigned a IP Address from the user provided subnet as an input.
- Create a Cloud Object Storage (COS) Bucket and upload the qcow2 image using
the methods described in _IBM COS getting started docs_ (https://test.cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-getting-started). This qcow2 image will be used to create a
custom image (https://cloud.ibm.com/docs/vpc?topic=vpc-managing-images) in the 
customer account by the terraform script. It's recommended to delete the
custom image after the vendor VNF is created by terraform.
- Copy the RHEL 7 qcow2 image to the COS bucket to install and create a VSI. Download the RHEL 7 qcow2 image, KVM Guest Image (rhel-guest-image-7.0-20140930.0.x86_64.qcow2) from https://access.redhat.com/downloads/content/69/ver=/rhel---7/7.0/x86_64/product-software
- Create a **READ ALL** permissions on the relevant bucket containing the qcow2
image using the method provided here (https://cloud.ibm.com/docs/cloud-object-storage/iam?topic=cloud-object-storage-iam-public-access#public-access-object). Here is an example for us-south region using
the IBM Cloud CLI (https://cloud.ibm.com/docs/cli?topic=cli-getting-started):

    $ export token=`ibmcloud iam oauth-tokens | awk '{ print $4 }'`
    $ curl -v -X “PUT” “https://s3.us-south.cloud-object-storage.appdomain.cloud/vendorbucketname/vendor.qcow2?acl” -H “Authorization: Bearer $token” -H “x-amz-acl: public-read”

## Costs

When you apply template, the infrastructure resources that you create incur charges as follows. To clean up the resources, you can [delete your Schematics workspace or your instance](https://cloud.ibm.com/docs/schematics?topic=schematics-manage-lifecycle#destroy-resources). Removing the workspace or the instance cannot be undone. Make sure that you back up any data that you must keep before you start the deletion process.


* _VPC_: VPC charges are incurred for the infrastructure resources within the VPC, as well as network traffic for internet data transfer. For more information, see [Pricing for VPC](https://cloud.ibm.com/docs/vpc-on-classic?topic=vpc-on-classic-pricing-for-vpc).
* _VPC Custom Image_: The template will copy over a custom RHEL 7 image - this can be a one time operation.  RHEL 7 virtual instances can be created from the custom image.  VPC charges per custom image.

## Dependencies

Before you can apply the template in IBM Cloud, complete the following steps.


1.  Ensure that you have the following permissions in IBM Cloud Identity and Access Management:
    * `Manager` service access role for IBM Cloud Schematics
    * `Operator` platform role for VPC Infrastructure
2.  Ensure the following resources exist in your VPC Gen 2 environment
    - VPC
    - SSH Key
    - VPC has a subnet
    - _(Optional):_ A Floating IP Address to assign to the RHEL7 instance post deployment

## Configuring your deployment values

Create a schematics workspace and provide the github repository url (https://github.com/IBM-Cloud/vnf-samples) under settings to pull the latest code, so that you can set up your deployment variables from the `Create` page. Once the template is applied, IBM Cloud Schematics  provisions the resources based on the values that were specified for the deployment variables.

### Required values
Fill in the following values, based on the steps that you completed before you began.

| Key | Definition | Value Example |
| --- | ---------- | ------------- | 
| `zone` | The VPC Zone that you want your VPC virtual servers to be provisioned. To list available zones, run `ibmcloud is zones` | us-south-1 |
| `region` | The VPC region that you want your VPC virtual servers to be provisioned. | us-south |
| `resource_group` | The resource group to use. If unspecified, the account's default resource group is used. To list available resource groups, run `ibmcloud resource groups` | Default | 
| `vpc_name` | The name of your VPC in which VSI is to be provisioned. | test-vpc |
| `ssh_key_name` | The name of your public SSH key to be used for VSI. Follow [Public SSH Key Doc](https://cloud.ibm.com/docs/vpc-on-classic-vsi?topic=vpc-on-classic-vsi-ssh-keys) for creating and managing ssh key. | linux-ssh-key |
| `ssh_key` | Copy the ssh key value for VSI. This will add the ssh key value in your RHEL 7 image. | ssh-rsa AAAA .......|
| `vnf_cos_image_url` | This is the vendor COS image SQL URL where the image(RHEL7 qcow2 image) is located. This is to copy the image from COS to VPC custom image in your IBM Cloud account VPC Infrastructure. First time, the image needs to be copied to your VPC cloud account. | cos://us-south/vnf-bucket/rhel-guest-image-7.0-20140930.0.x86_64.qcow2 |
| `vnf_vpc_image_name` | The starting name of the RHEL7 qcow2 Custom Image to be provisioned in your IBM Cloud account and (if already available) to be used to create the RHEL7 virtual server instance. The name is appended with UUID, to create a unique custom image for every run. | rhel7img |
| `vnf_profile` | The profile of compute CPU and memory resources to be used when provisioning the vnf instance. To list available profiles, run `ibmcloud is instance-profiles`. | bx2-2x8 |
| `vnf_instance_name` | The name of the VNF instance to be provisioned. | rhel7vsi |
| `subnet_id` | The ID of the subnet where the VNF instance will be deployed. Click on the subnet details in the VPC Subnet Listing to determine this value | 0717-xxxxxx-xxxx-xxxxx-8fae-xxxxx |

## Notes

If there is any failure during RHEL7 VSI creation, the created resources must be destroyed before attempting to instantiate again. To destroy resources go to `Schematics -> Workspaces -> [Your Workspace] -> Actions -> Delete` to delete  all associated resources. <br/>

# Post RHEL7 VSI Instance Spin-up

1. From the VPC list, confirm the RHEL7 VSI is powered ON with green button
2. Assign a Floating IP to the RHEL7-VSI. Refer the steps below to associate floating IP
    - Go to `VPC Infrastructure Gen 2` from IBM Cloud
    - Click `Floating IPs` from the left pane
    - Click `Reserve floating IP` -> Click `Reserve IP`
    - There will be a (new) Floating IP address with status `Unbind`
    - Click Three Dot Button corresponding to the Unbound IP address -> Click `Bind`
    - Select RHEL7 instance from `Instance to bind` column.
    - After clicking `Bind`, you can see the IP address assigned to your RHEL7-VSI Instance.
3. In the Security group,  here are the steps to open the port 8443
    - Go to `VPC Infrastructure Gen 2` from IBM Cloud
    - Click `Security groups` from the left pane
    - Click the security group which is corresponding to your VPC
    - Click `New Rule` in "Inbound Rules" column.
    - Select `Protocol` as "TCP"
    - Select `Port Range` under Port
    - Give `8443` port number in `Port min` and `Port max`
    - Select `Source type` as `Any`
    - Click `Save`, and a new rule will be added to your security group
4. From the CLI, run `ssh cloud-user@<Floating IP>`. 
5. Enter 'yes' for continue connecting using ssh your key. This is the ssh key value, you specified in ssh_key variable. 

