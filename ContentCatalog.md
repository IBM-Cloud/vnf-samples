# VNF on VPC Content Catalog Onboarding Procedure

## Pre-requisites

### VNF Vendor

(1) The VNF Vendor must have access to _IBM Cloud Account_ (https://cloud.ibm.com)
To register for a new account use https://cloud.ibm.com/registration.

(2) Create a Cloud Object Storage (COS) Bucket and upload the qcow2 image using
the methods described in _IBM COS getting started docs_ (https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-getting-started). Both test and production cloud
account COS must contain the qcow2 image. The Content Catalog onboarding
process will use the qcow2 image stored in the test.cloud account while a
customer will use the qcow2 image in the production or test account depending
on which type of account the customer is logged onto.

(3) Create a **READ ALL** permissions on the relevant bucket containing the qcow2
image using the method provided here (https://cloud.ibm.com/docs/cloud-object-storage/iam?topic=cloud-object-storage-iam-public-access#public-access-object). Here is an example for us-south region using
the IBM Cloud CLI (https://cloud.ibm.com/docs/cli?topic=cli-getting-started):

    $ export token=`ibmcloud iam oauth-tokens | awk '{ print $4 }'`
    $ curl -v -X “PUT” “https://s3.us-south.cloud-object-storage.appdomain.cloud/vendorbucketname/vendor.qcow2?acl” -H “Authorization: Bearer $token” -H “x-amz-acl: public-read”

Other region endpoints can be found at (https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-endpoints#endpoints-region)

(4) Provide the following COS values to the Content Catalog creator.

| Value | How to derive |
| ----- | ------------- |
| Image COS SQL URL | Navigate to the COS bucket and the vendor image using the IBM Cloud UI, determine the SQL URL of the image for e.g. `cos://us-south/vendorbucketname/vendor.qcow2` |

(5) Go through Cloud Object Storage FAQ page for helpful tips: https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-faq

### Content Catalog Creator

The Content Catalog creator can be in a separate account than the account where
the VNF qcow2 images are stored by usually the Content Catalog Creator belongs
to the VNF Vendor account.

(1) The catalog creator should have access to a personal account under 
_staging account_ (https://cloud.ibm.com). To register for a new account use 
https://cloud.ibm.com/registration.

(2) The ability to create and destroy _IBM Cloud Schematics_ (https://cloud.ibm.com/docs/schematics?topic=schematics-getting-started) workspaces.

(3) Knowledge about the vendor COS url location.

(4) Encouraged to watch the IBM Content Catalog onboarding tutorial video
(https://www.youtube.com/watch?v=Mzypz0JA-Xs&feature=emb_title)

##PLACEHOLER FOR SCHEMATIC TEAMS NEW CONTENT FOR WORKSPACE CREATION

## Content Catalog Creator Actions

### Terraform Templates

A list of sample terraform templates can be found at 
(https://github.com/IBM-Cloud/vnf-samples).

### Create a Release

* Create a Github release using these _instructions_ (https://help.github.com/en/github/administering-a-repository/creating-releases). It's highly recommended to create a tar.gz release of the terraform directory and use Step 7.

* Copy the link to Download URL (tar.gz) for e.g. https://github.com/IBM-Cloud/vnf-samples/releases/download/0.2/catalog_img_id_multinic_vsi.tar.gz

### Create the Offering

* Login to https://cloud.ibm.com

* Navigate to `Manage -> Catalogs`

* Click on `Create a Catalog`, give it a name.

* Click on the newly created Catalog and `Add -> New Offering`.

* Here, paste the Source Code URL (tar.gz) of the VNF Offering Terraform files and click Import Offering

* Edit the offering name and category by clicking on the edit button on the top, category can be Networking and VPC Infrastructure.

* Configure the Deployment Details as described below

### Deployment Values

There are 3 types of deployment values

* _The Vendor defined values:_ Some of these values MUST be hidden for e.g. Vendor 
Cloud IBM API Key, others SHOULD be hidden and some can be exposed to the Customer.

* _The Offering defined values:_ These can be hidden at the discretion of the 
Content Catalog creator for e.g. zone, VPC version etc. 

* _The Customer defined values:_ There can be some default values set for the
customer, but most of them will need to be filled in by the customer based
on the resources in their account.

#### Vendor defined values

| Key | Definition | Hidden | Password Protect |
| --- | ---------- | ------ | ---------------- | 
| vnf_cos_image_url | Image COS SQL URL for cloud.ibm.com account | Yes - Recommended | No |

#### Offering defined values

| Key | Definition | Values | Hidden |
| --- | ---------- | ------ | ------ |
| generation | The VPC Generation | 2 (default) | Yes - Recommended |
| region | The Region of the deployment | us-south (default) | No |

#### Customer defined values

All customer defined values are **required** and **MUST not be hidden**. Some
of these values will apply to all offerings, some will be specific to VNF type
and deployment model. Some common ones are listed below.

| Key | Definition | Default Value |
| --- | ---------- | ------------- |
| vnf_vpc_image_name | The name of the temporary vendor custom image that will be uploaded to customer VPC | _Depends on the offering_ | 
| vnf_profile | The profile of compute CPU and memory resources to be used when provisioning the vnf instance. To list available profiles, run `ibmcloud is instance-profiles`. | `bx2-2x8` |
| vnf_instance_name | The name of the VNF instance to be provisioned. | _Customer Choice_ |
| ssh_key_name | The name of the VPC public SSH key to be used when provisining | _Customer Choice_ |
| vpc_name | VPC name | _Customer Choice_ |
| subnet_id | The ID of the subnet where the VNF instance will be deployed. Click on the subnet details in the VPC Subnet Listing to determine this value | _Customer Choice_ |

Click Update after filling in the above values. All keys marked as "Customer Choice"
must be filled in by the Catalog Creator using their own existing VPC resources 
names/ids.
 
### Validate the Offering

Before Validating the Offering, make sure required resources have been 
created in the Content Catalog creator's VPC account for e.g. vpc, subnet, ssh
key etcs. Go to Validate Offering tab and in the deployment values fill in the
required values based on the Content Catalog creator's VPC Gen 2 resources 
from (https://cloud.ibm.com/vpc-ext). 

* Agree the licence and click on Validate.

* A new _schematic workspace_ (https://cloud.ibm.com/schematics/workspaces) will be created to validate the offering and it might take some time, click on refresh to know the status.


### Publish the Offering within the Account

Once validated successfully, click on Publish to Account in the **top left (TBD)**

### Publish the Offering to all IBM

**Warning** This procedure should only be executed after consulting with IBM Offering Managers.

**IBMers Only**: Once the content catalog creator submits a request for Publishing to all IBM Users, a new Github issue is created within IBM Github - https://github.ibm.com/ibmcloud/content-catalog/issues. Open the github issue and inside description, there will be Offering (like Offering :<offering_name>), we can get the URL for the offering from there by clicking on it.

Note: Once the Offering is approved and published, ALL users will be able to see the offering as Tile.

## Known Issues

* In case of partial failure/exception, while validating the offering, the user has to fix the terraform template input (if it is caused due to invalid input), then re-validate/re-run the offering procedure before move on to install new offerings in the same account.

> Note: In case, the user wishes to go for new offerings without troubleshooting the current one, then they have to delete associated resources in the current workspace and then delete the workspace before move on to create a new workspace/offerings. If this step is not done, then they might see some unexpected behavior like "conflict: auth policy already exists" (or) "unique image identifier failure".

