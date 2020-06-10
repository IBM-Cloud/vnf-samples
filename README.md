# vnf-samples
vnf-samples

# Redhat Linux Virtual Server for Virtual Private Cloud using Custom Image
  
Use this template to create RHEL 7 virtual server using custom image from your IBM Cloud account in IBM Cloud [VPC Gen2](https://cloud.ibm.com/vpc-ext/overview) by using Terraform or IBM Cloud Schematics.  Schematics uses Terraform as the infrastructure-as-code engine.  With this template, you can create and manage infrastructure as a single unit as follows. For more information about how to use this template, see the IBM Cloud [Schematics documentation](https://cloud.ibm.com/docs/schematics).


#IBM Cloud IaaS Support
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

