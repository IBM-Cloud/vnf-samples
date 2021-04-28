# Custom Image Sample

This directory contains the sample terraform code to create a Custom image from a qcow2 image stored in the COS URL. 


# IBM Cloud IaaS Support
You're provided free technical support through the IBM Cloud™ community and Stack Overflow, which you can access from the Support Center. The level of support that you select determines the severity that you can assign to support cases and your level of access to the tools available in the Support Center. Choose a Basic, Advanced, or Premium support plan to customize your IBM Cloud™ support experience for your business needs.

Learn more: https://www.ibm.com/cloud/support

## Prerequisites

- Have access to [Gen 2 VPC](https://cloud.ibm.com/vpc-ext/).
- Create a **Publicly Accessible** Cloud Object Storage (COS) Bucket and upload the qcow2 image using
the methods described in _IBM COS getting started docs_ (https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-getting-started-cloud-object-storage). This qcow2 image will be used to create a
custom image (https://cloud.ibm.com/docs/vpc?topic=vpc-managing-images) that can be used by terraform script later in the process. It's recommended to delete the
custom image after the VNF is created by terraform.
- Create a **READ ALL** permissions on the relevant bucket containing the qcow2
image using the method provided here (https://cloud.ibm.com/docs/cloud-object-storage/iam?topic=cloud-object-storage-iam-public-access#public-access-object). Here is an example for us-south region using
the IBM Cloud CLI (https://cloud.ibm.com/docs/cli?topic=cli-getting-started):

  <pre><code>$ export token=`ibmcloud iam oauth-tokens | awk '{ print $4 }'`
  $ curl -v -X "PUT" "https://s3.us-south.cloud-object-storage.appdomain.cloud/vendorbucketname/vendor.qcow2?acl" -H "Authorization: Bearer $token" -H "x-amz-acl: public-read"</code></pre>

## Costs

When you apply template, the infrastructure resources that you create incur charges as follows. To clean up the resources, you can [delete your Schematics workspace or your instance](https://cloud.ibm.com/docs/schematics?topic=schematics-manage-lifecycle#destroy-resources). Removing the workspace or the instance cannot be undone. Make sure that you back up any data that you must keep before you start the deletion process.


* _VPC_: VPC charges are incurred for the infrastructure resources within the VPC, as well as network traffic for internet data transfer. For more information, see [Pricing for VPC](https://cloud.ibm.com/docs/vpc-on-classic?topic=vpc-on-classic-pricing-for-vpc).
* _VPC Custom Image_: The template will copy over a custom Ubuntu 18.04 image - this can be a one time operation.  Ubuntu 18.04 virtual instances can be created from the custom image.  VPC charges per custom image.

## Dependencies

Before you can apply the template in IBM Cloud, complete the following steps.

Ensure that you have the following permissions in IBM Cloud Identity and Access Management:
    * `Manager` service access role for IBM Cloud Schematics
    * `Operator` platform role for VPC Infrastructure


## Configuring your deployment values

Create a schematics workspace and provide the github repository url (https://github.com/IBM-Cloud/vnf-samples/tree/master/custom_image_sample) under `Settings` to pull the latest terraform code from the Github repository. The deployment variables are generated from the terraform code. Fill in values for the various deployment variables and select `Apply Plan`. Once the template is applied, IBM Cloud Schematics  provisions the resources based on the values that were specified for the deployment variables. Tips on filling in the variable values can be found below.

### Required values
Fill in the following values, based on the steps that you completed before you began.

| Key | Definition | Value Example |
| --- | ---------- | ------------- | 
| `generation` | The VPC Generation 1 (classic) or Generation 2 that you want your VPC virtual servers to be provisioned. Only use Gen 2. | 2  |
| `vnf_cos_image_url` | The COS image SQL URL where the image(Ubuntu qcow2 image) is located. This copies the image from COS to VPC custom image in your IBM Cloud account VPC Infrastructure. First time, the image needs to be copied to your VPC cloud account. | cos://us-south/vnf-bucket/bionic-server-cloudimg-amd64.qcow2 |
| `vnf_vpc_image_name` | The name of the VSI image that will be provisioned. | ubuntu18-04-img |
| `region` | The VPC region to provision the VSI image in. To list regions: `ibmcloud is regions`| us-south |
| `image_operating_system` | Description of underlying OS of an image. To list available OSs: `ibmcloud is oses`| centos-7-amd64 |


## Notes

If there is any failure during Custom image creation, the created resources must be destroyed before attempting to create again. To destroy resources go to `Schematics -> Workspaces -> [Your Workspace] -> Actions -> Delete` to delete  all associated resources. <br/>

# Post Custom Image creation

The Custom image can be used to create Virtual Server Instance.
 
