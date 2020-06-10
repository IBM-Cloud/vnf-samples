# vnf-samples
vnf-samples

# Red hat Linux Virtual Server for Virtual Private Cloud using Custom Image
  
Use this template to create RHEL 7 virtual server using custom image from your IBM Cloud account in IBM Cloud [VPC Gen2](https://cloud.ibm.com/vpc-ext/overview) by using Terraform or IBM Cloud Schematics.  Schematics uses Terraform as the infrastructure-as-code engine.  With this template, you can create and manage infrastructure as a single unit as follows. For more information about how to use this template, see the IBM Cloud [Schematics documentation](https://cloud.ibm.com/docs/schematics).


# IBM Cloud IaaS Support
You're provided free technical support through the IBM Cloud™ community and Stack Overflow, which you can access from the Support Center. The level of support that you select determines the severity that you can assign to support cases and your level of access to the tools available in the Support Center. Choose a Basic, Advanced, or Premium support plan to customize your IBM Cloud™ support experience for your business needs.

Learn more: https://www.ibm.com/cloud/support

## Prerequisites

- Must have access to [Gen 2 VPC](https://cloud.ibm.com/vpc-ext/network/vpcs).
- The given VPC must have at least one subnet IP address unassigned - the RHEL 7 VSI will be assigned a IP Address from the user provided subnet as an input.
- Must copy the RHEL 7 qcow2 image to COS bucket to install and create a VSI. Download the RHEL 7 qcow2 image, KVM Guest Image (rhel-guest-image-7.0-20140930.0.x86_64.qcow2) from https://access.redhat.com/downloads/content/69/ver=/rhel---7/7.0/x86_64/product-software 

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

Create a schematics workspace and provide the github url (), so you can set up your deployment variables from the `Create` page. Once the template is applied, IBM Cloud Schematics  provisions the resources based on the values that were specified for the deployment variables.

### Required values
Fill in the following values, based on the steps that you completed before you began.

| Key | Definition |
| --- | ---------- |
| `zone` | The VPC Zone that you want your VPC virtual servers to be provisioned. To list available zones, run `ibmcloud is zones` |
| `resource_group` | The resource group to use. If unspecified, the account's default resource group is used. To list available resource groups, run `ibmcloud resource groups` |
| `vpc_name` | The name of your VPC in which F5-BIGIP VSI is to be provisioned. |
| `ssh_key_name` | The name of your public SSH key to be used for F5-BIGIP VSI. Follow [Public SSH Key Doc](https://cloud.ibm.com/docs/vpc-on-classic-vsi?topic=vpc-on-classic-vsi-ssh-keys) for creating and managing ssh key. |
| `vnf_image_copy` | Copy vendor custom image to your IBM Cloud account VPC Infrastructure (y/n)? First time, the image needs to be copied to your cloud account. It should be `y` for the first time. For the next runs, customer can skip image copy, if image is already copied by entering `n`. Accepted values in this field are `y` or `n` |
| `vnf_vpc_image_name` | The name of the F5 Custom Image to be provisioned in your IBM Cloud account and (if already available) to be used to create the F5-BIGIP virtual server instance. |
| `vnf_profile` | The profile of compute CPU and memory resources to be used when provisioning the vnf instance. To list available profiles, run `ibmcloud is instance-profiles`. |
| `vnf_instance_name` | The name of the VNF instance to be provisioned. |
| `subnet_id` | The ID of the subnet where the VNF instance will be deployed. Click on the subnet details in the VPC Subnet Listing to determine this value |
| `ibmcloud_endpoint` | The IBM Cloud environment `cloud.ibm.com` or `test.cloud.ibm.com` |
| `delete_custom_image_confirmation` | A confirmation from the user to delete the custom image post successful creation of VSI |
