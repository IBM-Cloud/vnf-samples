## Schematics API - Multi NIC F5 Provisioning

This document provides the steps to provision multi NIC using F5  IBM Schematics API Curl Commands .

### 1.	Create tokens:
access_token and refresh_token need to be created first.

Command to create them is 

<pre><code>export IBMCLOUD_API_KEY=&lt;ibmcloud_api_key>
curl -X POST "https://iam.cloud.ibm.com/identity/token" -H "Content-Type: application/x-www-form-urlencoded" -d "grant_type=urn:ibm:params:oauth:grant-type:apikey&apikey=$IBMCLOUD_API_KEY" -u bx:bx
</code></pre>

The "access_token" is considered as iam_token or bearer token. It can be used by appending "Bearer" keyword before it.

<pre><code>Example: 

curl -X POST "https://iam.cloud.ibm.com/identity/token" -H "Content-Type: application/x-www-form-urlencoded" -d "grant_type=urn:ibm:params:oauth:grant-type:apikey&apikey=$IBMCLOUD_API_KEY" -u bx:bx | jq
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  2469  100  2368  100   101    380     16  0:00:06  0:00:06 --:--:--   607
{
  "access_token": "eyJraxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "refresh_token": "OKDSlxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "ims_user_id": 8009626,
  "token_type": "Bearer",
  "expires_in": 3600,
  "expiration": 1593170371,
  "scope": "ibm openid"
} 
</code></pre>

### 2.  Export the access_token and refresh_token obtained in step 1 as environment variables as ACCESS_TOKEN and REFRESH_TOKEN respectively.

<pre><code>export ACCESS_TOKEN=&lt;access_token>
export REFRESH_TOKEN=&lt;refresh_token>
</code></pre>


### 3.  Create workspace.

 Create a schematic workspace in Frankfurt as show below,
 <pre><code>curl --request POST --url https://eu-de.schematics.cloud.ibm.com/v1/workspaces -H "Authorization: Bearer &lt;access_token>" -d '{"name":"<workspace_name>","type": ["terraform_v0.12"],"description": "<workspace_description>","resource_group": "<resource_group_ID>","tags": [],"template_repo": {"url": "<source_repo_url>"},"template_data": [{"folder": ".","type": "terraform_v0.12","variablestore": [{"name": "variable_name1","value": "variable_value1"},{"name": "variable_name2","value": "variable_value2"}]}]}'
</code></pre>


```
request.json :

{
"name":"catalog-sample1",
"type": ["terraform_v0.12"],
"location": "eu-de",
"description": "Test schematics", 
"resource_group": "37bb11cc41794f52adebc2e2b0d583ee",
 "tags": [], 
 "template_repo": {
 
"url": "https://github.com/IBM-Cloud/vnf-samples/tree/master/catalog_img_id_multinic_vsi"
 },
 "template_data": [
 {
   "folder": ".",
   "type": "terraform_v0.12",
   "variablestore": [
    {
	  "name": "zone",
	  "value": "eu-fr2-1"
	},
    {
	 "name": "vpc_name",
	 "value": "test-vpc-demo-1"
	}, 
	{
	"name": "primary_subnet_id", 
	"value": "02k7-71501954-6828-45da-a327-5b15f05e86d5"
	}, 
	{
	"name": "secondary_subnet_id_1", 
	"value": "02k7-c84c0c1a-4602-45df-8836-d0960bcacc69"
	},
	{
	"name": "secondary_subnet_id_2", 
	"value": "02k7-0cd7c739-dbb9-4b2c-ba07-89ed3867aa6c"
	},
	{
	 "name": "ssh_key_name", 
	 "value": "my-key-1"
	 }, 
	 {
	  "name": "image_name", 
	  "value": "bigip-15-1-0-4-0-0-6-ltm-1slot"
	 }, 
	 {
	  "name": "vnf_instance_name", 
	  "value": "f5-bnpp-sch-vsi"
	 }, 
	 {
	   "name": "vnf_profile", 
	   "value": "bx2-2x8"
	 }, 
	 {
	    "name": "region", 
		"value": "eu-fr2"
     },
	 {
		"name": "resource_group",
	    "value": "Default"
	 }, 
	 {
	   "name": "vnf_security_group", 
	   "value": "f5-schapi-security-group33"
	 }
	]
  }
 ]
}

```
 <pre><code>
curl --request POST --url https://eu-de.schematics.cloud.ibm.com/v1/workspaces -H "Authorization: Bearer $ACCESS_TOKEN" H "Content-Type: application/json"  --data @request.json | jq
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  4140    0  2931  100  1209    156     64  0:00:18  0:00:18 --:--:--   673
  0     0    0     0    0     0      0      0 --:--:--  0:00:04 --:--:--     0curl: (6) Could not resolve host: H
curl: (3) URL using bad/illegal format or missing URL
{
 ## "id": "catalog-sample1-2338c1ba-e914-42",
  "name": "catalog-sample1",
  "crn": "crn:v1:bluemix:public:schematics:eu-de:a/322c285df3be4e90b19faabf6341f632:273d1665-25ab-447d-997f-4a957ed83fc2:workspace:catalog-sample1-2338c1ba-e914-42",
  "type": [
    "terraform_v0.12"
  ],
  "description": "Test schematics",
  "resource_group": "Default",
  "location": "eu-de",
  "tags": [],
  "created_at": "2020-10-07T06:25:34.197963319Z",
  "created_by": "pinky.bhargava@in.ibm.com",
  "status": "DRAFT",
  "workspace_status_msg": {
    "status_code": "",
    "status_msg": ""
  },
  "workspace_status": {
    "frozen": false,
    "locked": false
  },
  "template_repo": {
    "url": "https://github.com/IBM-Cloud/vnf-samples",
    "branch": "master",
    "full_url": "https://github.com/IBM-Cloud/vnf-samples/tree/master/catalog_img_id_multinic_vsi",
    "has_uploadedgitrepotar": false
  },
  "template_data": [
    {
    ##  "id": "catalog_img_id_multinic_vsi-6d9da9ff-b7da-45",
      "folder": "catalog_img_id_multinic_vsi",
      "type": "terraform_v0.12",
      "values_url": "https://eu-de.schematics.cloud.ibm.com/v1/workspaces/catalog-sample1-2338c1ba-e914-42/template_data/catalog_img_id_multinic_vsi-6d9da9ff-b7da-45/values",
      "values": "",
      "variablestore": [
        {
          "name": "zone",
          "secure": false,
          "value": "eu-fr2-1",
          "type": "",
          "description": ""
        },
        {
          "name": "vpc_name",
          "secure": false,
          "value": "test-vpc-demo-1",
          "type": "",
          "description": ""
        },
        {
          "name": "primary_subnet_id",
          "secure": false,
          "value": "02k7-71501954-6828-45da-a327-5b15f05e86d5",
          "type": "",
          "description": ""
        },
        {
          "name": "secondary_subnet_id_1",
          "secure": false,
          "value": "02k7-c84c0c1a-4602-45df-8836-d0960bcacc69",
          "type": "",
          "description": ""
        },
        {
          "name": "secondary_subnet_id_2",
          "secure": false,
          "value": "02k7-0cd7c739-dbb9-4b2c-ba07-89ed3867aa6c",
          "type": "",
          "description": ""
        },
        {
          "name": "ssh_key_name",
          "secure": false,
          "value": "my-key-1",
          "type": "",
          "description": ""
        },
        {
          "name": "image_name",
          "secure": false,
          "value": "bigip-15-1-0-4-0-0-6-ltm-1slot",
          "type": "",
          "description": ""
        },
        {
          "name": "vnf_instance_name",
          "secure": false,
          "value": "f5-bnpp-sch-vsi",
          "type": "",
          "description": ""
        },
        {
          "name": "vnf_profile",
          "secure": false,
          "value": "bx2-2x8",
          "type": "",
          "description": ""
        },
        {
          "name": "region",
          "secure": false,
          "value": "eu-fr2",
          "type": "",
          "description": ""
        },
        {
          "name": "resource_group",
          "secure": false,
          "value": "Default",
          "type": "",
          "description": ""
        },
        {
          "name": "vnf_security_group",
          "secure": false,
          "value": "f5-schapi-security-group33",
          "type": "",
          "description": ""
        }
      ],
      "has_githubtoken": false
    }
  ],
  "runtime_data": [
    {
      "id": "catalog_img_id_multinic_vsi-6d9da9ff-b7da-45",
      "engine_name": "terraform",
      "engine_version": "v0.12.20",
      "state_store_url": "https://eu-de.schematics.cloud.ibm.com/v1/workspaces/catalog-sample1-2338c1ba-e914-42/runtime_data/catalog_img_id_multinic_vsi-6d9da9ff-b7da-45/state_store",
      "log_store_url": "https://eu-de.schematics.cloud.ibm.com/v1/workspaces/catalog-sample1-2338c1ba-e914-42/runtime_data/catalog_img_id_multinic_vsi-6d9da9ff-b7da-45/log_store"
    }
  ],
  "shared_data": {
    "resource_group_id": ""
  },
  "applied_shareddata_ids": null,
  "updated_at": "0001-01-01T00:00:00Z",
  "last_health_check_at": "0001-01-01T00:00:00Z"
}
</code></pre>

4.	Terraform Plan 

    Terraform Plan command can be executed using below curl command.

<pre><code>curl -X POST https://eu-de.schematics.cloud.ibm.com/v1/workspaces/{id}/plan -H "Authorization: Bearer &lt;access_token>" -H "refresh_token: &lt;refresh_token>"
</code></pre>

In above command “id” is the schematics id obtained from step 3 output. 

<pre><code>Example:

curl -X POST https://schematics.cloud.ibm.com/v1/workspaces/catalog-sample1-376ad599-b556-4d/plan -H "Authorization: Bearer $ACCESS_TOKEN" -H "refresh_token: $REFRESH_TOKEN" | jq
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100    49  100    49    0     0     14      0  0:00:03  0:00:03 --:--:--    14
{
  "activityid": "446b10e893da75987f6e8753e09f2cb6"
}
</code></pre>

### 5.	Terraform Apply
    
    Terraform Apply can be performed using below curl command.

<pre><code>curl -X PUT https://eu-de.schematics.cloud.ibm.com/v1/workspaces/{id}/apply -H "Authorization: Bearer &lt;access_token>" -H "refresh_token: &lt;refresh_token>"
</code></pre>

<pre><code>Example:

 curl -X PUT https://eu-de.schematics.cloud.ibm.com/v1/workspaces/catalog-sample1-2338c1ba-e914-42/apply -H "Authorization: Bearer  $ACCESS_TOKEN" -H "refresh_token:$REFRESH_TOKEN"
{"activityid":"0c7249c9fb4e0c3d30d2beac85eb195e"}

</code></pre>

### 6.	Get log for the latest activity

    Show the Terraform logs for the most recent action of a template that ran against your workspace.

<pre><code>curl -X GET https://eu-de.schematics.cloud.ibm.com/v1/workspaces/{id}/runtime_data/{template_id}/log_store -H "Authorization: <iam_token>"
</code></pre>
In above command 
“id” : it is the schematics id obtained from step 3 output. 
”template_id ” : The ID that was assigned to your Terraform template or IBM Cloud catalog software template and is obtained from step 3 output.


<pre><code>Example:
curl -X GET https://eu-de.schematics.cloud.ibm.com/v1/workspaces/catalog-sample1-2338c1ba-e914-42/runtime_data/catalog_img_id_multinic_vsi-6d9da9ff-b7da-45/log_store -H "Authorization: Bearer  $ACCESS_TOKEN" 

 2020/10/07 06:37:31 -----  New Workspace Action  -----
 2020/10/07 06:37:31 Request: activitId=0c7249c9fb4e0c3d30d2beac85eb195e, account=322c285df3be4e90b19faabf6341f632, owner=pinky.bhargava@in.ibm.com, requestID=a3e6a40e-43a3-4030-a5b3-0633bb4d00d4
 2020/10/07 06:37:31 Related Activity: action=APPLY, workspaceID=catalog-sample1-2338c1ba-e914-42, processedBy=orchestrator-5554c87678-s5844
 2020/10/07 06:37:31 Related Workspace: name=catalog-sample1, sourcerelease=(not specified), sourceurl=https://github.com/IBM-Cloud/vnf-samples
 2020/10/07 06:37:35  --- Ready to execute the command --- 
 2020/10/07 06:37:36 workspace.template.SecFile: 11999ebb-4d81-4e3b-91c6-a71cc3832f56
 2020/10/07 06:37:35 -----  New Action  -----
 2020/10/07 06:37:35 Request: requestID=a3e6a40e-43a3-4030-a5b3-0633bb4d00d4
 2020/10/07 06:37:36 Related Activity: action=Apply, workspaceID=catalog-sample1-2338c1ba-e914-42, processedByOrchestrator=a3e6a40e-43a3-4030-a5b3-0633bb4d00d4_0c7249c9fb4e0c3d30d2beac85eb195e, processedByJob=job12-599bf9678f-2q7c7
 
 2020/10/07 06:37:41 -----  Terraform INIT  -----
 2020/10/07 06:37:41 Starting command: terraform init -input=false -lock=false -no-color
 2020/10/07 06:37:42 Terraform init | 
 2020/10/07 06:37:42 Terraform init | Initializing the backend...
 2020/10/07 06:37:42 Terraform init | 
 2020/10/07 06:37:42 Terraform init | Initializing provider plugins...
 2020/10/07 06:37:42 Terraform init | 
 2020/10/07 06:37:42 Terraform init | The following providers do not have any version constraints in configuration,
 2020/10/07 06:37:42 Terraform init | so the latest version was installed.
 2020/10/07 06:37:42 Terraform init | 
 2020/10/07 06:37:42 Terraform init | To prevent automatic upgrades to new major versions that may contain breaking
 2020/10/07 06:37:42 Terraform init | changes, it is recommended to add version = "..." constraints to the
 2020/10/07 06:37:42 Terraform init | corresponding provider blocks in configuration, with the constraint strings
 2020/10/07 06:37:42 Terraform init | suggested below.
 2020/10/07 06:37:42 Terraform init | 
 2020/10/07 06:37:42 Terraform init | * provider.ibm: version = "~> 1.13"
 2020/10/07 06:37:42 Terraform init | 
 2020/10/07 06:37:42 Terraform init | Terraform has been successfully initialized!
 2020/10/07 06:37:42 Command finished successfully.
 
 2020/10/07 06:37:42 -----  Terraform SHOW  -----
 2020/10/07 06:37:42 Starting command: terraform show -no-color
 2020/10/07 06:37:44 Terraform show | No state.
 2020/10/07 06:37:44 Command finished successfully.
 
 2020/10/07 06:37:44 -----  Terraform APPLY  -----
 2020/10/07 06:37:44 Starting command: terraform apply -state=terraform.tfstate -var-file=schematics.tfvars -auto-approve -no-color -lock=false -parallelism=10
 2020/10/07 06:37:48 Terraform apply | data.ibm_is_subnet.vnf_primary_subnet: Refreshing state...
 2020/10/07 06:37:48 Terraform apply | data.ibm_is_region.region: Refreshing state...
 2020/10/07 06:37:48 Terraform apply | data.ibm_is_instance_profile.vnf_profile: Refreshing state...
 2020/10/07 06:37:48 Terraform apply | data.ibm_is_ssh_key.vnf_ssh_pub_key: Refreshing state...
 2020/10/07 06:37:54 Terraform apply | ibm_is_security_group.vnf_security_group: Creating...
 2020/10/07 06:37:57 Terraform apply | ibm_is_security_group.vnf_security_group: Creation complete after 4s [id=r030-d9d66cec-2126-4f0a-bbaa-c0e10cdd35bc]
 2020/10/07 06:37:57 Terraform apply | ibm_is_security_group_rule.vnf_sg_allow_ssh: Creating...
 2020/10/07 06:37:57 Terraform apply | ibm_is_security_group_rule.vnf_sg_allow_ssh: Creation complete after 0s [id=r030-d9d66cec-2126-4f0a-bbaa-c0e10cdd35bc.r030-589fee55-edef-4b92-925e-6889e6d0e1d1]
 2020/10/07 06:37:57 Terraform apply | ibm_is_security_group_rule.vnf_sg_rule_in_all: Creating...
 2020/10/07 06:37:57 Terraform apply | ibm_is_security_group_rule.vnf_sg_rule_in_all: Creation complete after 0s [id=r030-d9d66cec-2126-4f0a-bbaa-c0e10cdd35bc.r030-f43da5dd-0c59-4330-80e1-e19975b3fa41]
 2020/10/07 06:37:57 Terraform apply | ibm_is_security_group_rule.vnf_sg_rule_out_all: Creating...
 2020/10/07 06:37:57 Terraform apply | ibm_is_security_group_rule.vnf_sg_rule_out_all: Creation complete after 0s [id=r030-d9d66cec-2126-4f0a-bbaa-c0e10cdd35bc.r030-0a2826c7-829d-4d93-82d6-1c05688b6752]
 2020/10/07 06:37:57 Terraform apply | ibm_is_instance.vnf_vsi: Creating...
 2020/10/07 06:38:07 Terraform apply | ibm_is_instance.vnf_vsi: Still creating... [10s elapsed]
 2020/10/07 06:38:17 Terraform apply | ibm_is_instance.vnf_vsi: Still creating... [20s elapsed]
 2020/10/07 06:38:27 Terraform apply | ibm_is_instance.vnf_vsi: Still creating... [30s elapsed]
 2020/10/07 06:38:37 Terraform apply | ibm_is_instance.vnf_vsi: Still creating... [40s elapsed]
 2020/10/07 06:38:47 Terraform apply | ibm_is_instance.vnf_vsi: Still creating... [50s elapsed]
 2020/10/07 06:38:50 Terraform apply | ibm_is_instance.vnf_vsi: Provisioning with 'safe-local-exec'...
 2020/10/07 06:38:50 Terraform apply | ibm_is_instance.vnf_vsi (safe-local-exec): Executing: ["/bin/sh" "-c" "sleep 30"]
 2020/10/07 06:38:57 Terraform apply | ibm_is_instance.vnf_vsi: Still creating... [1m0s elapsed]
 2020/10/07 06:39:07 Terraform apply | ibm_is_instance.vnf_vsi: Still creating... [1m10s elapsed]
 2020/10/07 06:39:17 Terraform apply | ibm_is_instance.vnf_vsi: Still creating... [1m20s elapsed]
 2020/10/07 06:39:20 Terraform apply | ibm_is_instance.vnf_vsi: Creation complete after 1m22s [id=02k7_4719bd69-5c11-4b1f-b27e-06c870bb7da1]
 2020/10/07 06:39:20 Terraform apply | 
 2020/10/07 06:39:20 Terraform apply | Warning: Value for undeclared variable
 2020/10/07 06:39:20 Terraform apply | 
 2020/10/07 06:39:20 Terraform apply | The root module does not declare a variable named "resource_group" but a value
 2020/10/07 06:39:20 Terraform apply | was found in file "schematics.tfvars". To use this value, add a "variable"
 2020/10/07 06:39:20 Terraform apply | block to the configuration.
 2020/10/07 06:39:20 Terraform apply | 
 2020/10/07 06:39:20 Terraform apply | Using a variables file to set an undeclared variable is deprecated and will
 2020/10/07 06:39:20 Terraform apply | become an error in a future release. If you wish to provide certain "global"
 2020/10/07 06:39:20 Terraform apply | settings to all configurations in your organization, use TF_VAR_...
 2020/10/07 06:39:20 Terraform apply | environment variables to set these instead.
 2020/10/07 06:39:20 Terraform apply | 
 2020/10/07 06:39:20 Terraform apply | 
 2020/10/07 06:39:20 Terraform apply | Warning: Value for undeclared variable
 2020/10/07 06:39:20 Terraform apply | 
 2020/10/07 06:39:20 Terraform apply | The root module does not declare a variable named "zone" but a value was found
 2020/10/07 06:39:20 Terraform apply | in file "schematics.tfvars". To use this value, add a "variable" block to the
 2020/10/07 06:39:20 Terraform apply | configuration.
 2020/10/07 06:39:20 Terraform apply | 
 2020/10/07 06:39:20 Terraform apply | Using a variables file to set an undeclared variable is deprecated and will
 2020/10/07 06:39:20 Terraform apply | become an error in a future release. If you wish to provide certain "global"
 2020/10/07 06:39:20 Terraform apply | settings to all configurations in your organization, use TF_VAR_...
 2020/10/07 06:39:20 Terraform apply | environment variables to set these instead.
 2020/10/07 06:39:20 Terraform apply | 
 2020/10/07 06:39:20 Terraform apply | 
 2020/10/07 06:39:20 Terraform apply | Warning: Value for undeclared variable
 2020/10/07 06:39:20 Terraform apply | 
 2020/10/07 06:39:20 Terraform apply | The root module does not declare a variable named "vpc_name" but a value was
 2020/10/07 06:39:20 Terraform apply | found in file "schematics.tfvars". To use this value, add a "variable" block
 2020/10/07 06:39:20 Terraform apply | to the configuration.
 2020/10/07 06:39:20 Terraform apply | 
 2020/10/07 06:39:20 Terraform apply | Using a variables file to set an undeclared variable is deprecated and will
 2020/10/07 06:39:20 Terraform apply | become an error in a future release. If you wish to provide certain "global"
 2020/10/07 06:39:20 Terraform apply | settings to all configurations in your organization, use TF_VAR_...
 2020/10/07 06:39:20 Terraform apply | environment variables to set these instead.
 2020/10/07 06:39:20 Terraform apply | 
 2020/10/07 06:39:20 Terraform apply | 
 2020/10/07 06:39:20 Terraform apply | Warning: Values for undeclared variables
 2020/10/07 06:39:20 Terraform apply | 
 2020/10/07 06:39:20 Terraform apply | In addition to the other similar warnings shown, 1 other variable(s) defined
 2020/10/07 06:39:20 Terraform apply | without being declared.
 2020/10/07 06:39:20 Terraform apply | 
 2020/10/07 06:39:20 Terraform apply | 
 2020/10/07 06:39:20 Terraform apply | Warning: Interpolation-only expressions are deprecated
 2020/10/07 06:39:20 Terraform apply | 
 2020/10/07 06:39:20 Terraform apply |   on compute.tf line 30, in resource "ibm_is_security_group" "vnf_security_group":
 2020/10/07 06:39:20 Terraform apply |   30:   name           = "${var.vnf_security_group}"
 2020/10/07 06:39:20 Terraform apply | 
 2020/10/07 06:39:20 Terraform apply | Terraform 0.11 and earlier required all non-constant expressions to be
 2020/10/07 06:39:20 Terraform apply | provided via interpolation syntax, but this pattern is now deprecated. To
 2020/10/07 06:39:20 Terraform apply | silence this warning, remove the "${ sequence from the start and the }"
 2020/10/07 06:39:20 Terraform apply | sequence from the end of this expression, leaving just the inner expression.
 2020/10/07 06:39:20 Terraform apply | 
 2020/10/07 06:39:20 Terraform apply | Template interpolation syntax is still used to construct strings from
 2020/10/07 06:39:20 Terraform apply | expressions when the template includes multiple interpolation sequences or a
 2020/10/07 06:39:20 Terraform apply | mixture of literal strings and interpolations. This deprecation applies only
 2020/10/07 06:39:20 Terraform apply | to templates that consist entirely of a single interpolation sequence.
 2020/10/07 06:39:20 Terraform apply | 
 2020/10/07 06:39:20 Terraform apply | (and 13 more similar warnings elsewhere)
 2020/10/07 06:39:20 Terraform apply | 
 2020/10/07 06:39:20 Terraform apply | 
 2020/10/07 06:39:20 Terraform apply | Warning: Quoted references are deprecated
 2020/10/07 06:39:20 Terraform apply | 
 2020/10/07 06:39:20 Terraform apply |   on compute.tf line 37, in resource "ibm_is_security_group_rule" "vnf_sg_allow_ssh":
 2020/10/07 06:39:20 Terraform apply |   37:   depends_on = ["ibm_is_security_group.vnf_security_group"]
 2020/10/07 06:39:20 Terraform apply | 
 2020/10/07 06:39:20 Terraform apply | In this context, references are expected literally rather than in quotes.
 2020/10/07 06:39:20 Terraform apply | Terraform 0.11 and earlier required quotes, but quoted references are now
 2020/10/07 06:39:20 Terraform apply | deprecated and will be removed in a future version of Terraform. Remove the
 2020/10/07 06:39:20 Terraform apply | quotes surrounding this reference to silence this warning.
 2020/10/07 06:39:20 Terraform apply | 
 2020/10/07 06:39:20 Terraform apply | (and 3 more similar warnings elsewhere)
 2020/10/07 06:39:20 Terraform apply | 
 2020/10/07 06:39:20 Terraform apply | 
 2020/10/07 06:39:20 Terraform apply | Apply complete! Resources: 5 added, 0 changed, 0 destroyed.
 2020/10/07 06:39:20 Terraform apply | 
 2020/10/07 06:39:20 Terraform apply | Outputs:
 2020/10/07 06:39:20 Terraform apply | 
 2020/10/07 06:39:20 Terraform apply | map_instance = r030-88b35711-82aa-45ae-b0e6-12785e7c2b55
 2020/10/07 06:39:20 Command finished successfully.
 
 2020/10/07 06:39:20 -----  Terraform SHOW  -----
 2020/10/07 06:39:20 Starting command: terraform show -no-color
 2020/10/07 06:39:21 Terraform show | # data.ibm_is_instance_profile.vnf_profile:
 2020/10/07 06:39:21 Terraform show | data "ibm_is_instance_profile" "vnf_profile" {
 2020/10/07 06:39:21 Terraform show |     family = "balanced"
 2020/10/07 06:39:21 Terraform show |     id     = "bx2-2x8"
 2020/10/07 06:39:21 Terraform show |     name   = "bx2-2x8"
 2020/10/07 06:39:21 Terraform show | }
 2020/10/07 06:39:21 Terraform show | 
 2020/10/07 06:39:21 Terraform show | # data.ibm_is_region.region:
 2020/10/07 06:39:21 Terraform show | data "ibm_is_region" "region" {
 2020/10/07 06:39:21 Terraform show |     endpoint = "https://eu-fr2.iaas.cloud.ibm.com"
 2020/10/07 06:39:21 Terraform show |     id       = "eu-fr2"
 2020/10/07 06:39:21 Terraform show |     name     = "eu-fr2"
 2020/10/07 06:39:21 Terraform show |     status   = "available"
 2020/10/07 06:39:21 Terraform show | }
 2020/10/07 06:39:21 Terraform show | 
 2020/10/07 06:39:21 Terraform show | # data.ibm_is_ssh_key.vnf_ssh_pub_key:
 2020/10/07 06:39:21 Terraform show | data "ibm_is_ssh_key" "vnf_ssh_pub_key" {
 2020/10/07 06:39:21 Terraform show |     fingerprint             = "SHA256:b5UKj2h+us17bqG4yF3LmU7glDFr2tgDidWLffJswy4"
 2020/10/07 06:39:21 Terraform show |     id                      = "r030-f9616aea-8fdf-4fbe-8dca-eb9c29562d80"
 2020/10/07 06:39:21 Terraform show |     length                  = 4096
 2020/10/07 06:39:21 Terraform show |     name                    = "my-key-1"
 2020/10/07 06:39:21 Terraform show |     resource_controller_url = "https://cloud.ibm.com/vpc/compute/sshKeys"
 2020/10/07 06:39:21 Terraform show |     resource_crn            = "crn:v1:bluemix:public:is:eu-fr2:a/322c285df3be4e90b19faabf6341f632::key:r030-f9616aea-8fdf-4fbe-8dca-eb9c29562d80"
 2020/10/07 06:39:21 Terraform show |     resource_group_name     = "37bb11cc41794f52adebc2e2b0d583ee"
 2020/10/07 06:39:21 Terraform show |     resource_name           = "my-key-1"
 2020/10/07 06:39:21 Terraform show |     type                    = "rsa"
 2020/10/07 06:39:21 Terraform show | }
 2020/10/07 06:39:21 Terraform show | 
 2020/10/07 06:39:21 Terraform show | # data.ibm_is_subnet.vnf_primary_subnet:
 2020/10/07 06:39:21 Terraform show | data "ibm_is_subnet" "vnf_primary_subnet" {
 2020/10/07 06:39:21 Terraform show |     id                       = "02k7-71501954-6828-45da-a327-5b15f05e86d5"
 2020/10/07 06:39:21 Terraform show |     identifier               = "02k7-71501954-6828-45da-a327-5b15f05e86d5"
 2020/10/07 06:39:21 Terraform show |     ipv4_cidr_block          = "10.247.0.0/24"
 2020/10/07 06:39:21 Terraform show |     name                     = "mgmt"
 2020/10/07 06:39:21 Terraform show |     network_acl              = "r030-4bae82de-462d-4f68-8529-870e7c439b52"
 2020/10/07 06:39:21 Terraform show |     resource_controller_url  = "https://cloud.ibm.com/vpc-ext/network/subnets"
 2020/10/07 06:39:21 Terraform show |     resource_crn             = "crn:v1:bluemix:public:is:eu-fr2-1:a/322c285df3be4e90b19faabf6341f632::subnet:02k7-71501954-6828-45da-a327-5b15f05e86d5"
 2020/10/07 06:39:21 Terraform show |     resource_group           = "37bb11cc41794f52adebc2e2b0d583ee"
 2020/10/07 06:39:21 Terraform show |     resource_group_name      = "Default"
 2020/10/07 06:39:21 Terraform show |     resource_name            = "mgmt"
 2020/10/07 06:39:21 Terraform show |     resource_status          = "available"
 2020/10/07 06:39:21 Terraform show |     status                   = "available"
 2020/10/07 06:39:21 Terraform show |     total_ipv4_address_count = 256
 2020/10/07 06:39:21 Terraform show |     vpc                      = "r030-62a1cb21-9b36-4589-bdc4-a1fc1bbbcce7"
 2020/10/07 06:39:21 Terraform show |     zone                     = "eu-fr2-1"
 2020/10/07 06:39:21 Terraform show | }
 2020/10/07 06:39:21 Terraform show | 
 2020/10/07 06:39:21 Terraform show | # ibm_is_instance.vnf_vsi:
 2020/10/07 06:39:21 Terraform show | resource "ibm_is_instance" "vnf_vsi" {
 2020/10/07 06:39:21 Terraform show |     gpu                     = []
 2020/10/07 06:39:21 Terraform show |     id                      = "02k7_4719bd69-5c11-4b1f-b27e-06c870bb7da1"
 2020/10/07 06:39:21 Terraform show |     image                   = "r030-88b35711-82aa-45ae-b0e6-12785e7c2b55"
 2020/10/07 06:39:21 Terraform show |     keys                    = [
 2020/10/07 06:39:21 Terraform show |         "r030-f9616aea-8fdf-4fbe-8dca-eb9c29562d80",
 2020/10/07 06:39:21 Terraform show |     ]
 2020/10/07 06:39:21 Terraform show |     memory                  = 8
 2020/10/07 06:39:21 Terraform show |     name                    = "f5-bnpp-sch-vsi"
 2020/10/07 06:39:21 Terraform show |     profile                 = "bx2-2x8"
 2020/10/07 06:39:21 Terraform show |     resource_controller_url = "https://cloud.ibm.com/vpc-ext/compute/vs"
 2020/10/07 06:39:21 Terraform show |     resource_crn            = "crn:v1:bluemix:public:is:eu-fr2-1:a/322c285df3be4e90b19faabf6341f632::instance:02k7_4719bd69-5c11-4b1f-b27e-06c870bb7da1"
 2020/10/07 06:39:21 Terraform show |     resource_group          = "37bb11cc41794f52adebc2e2b0d583ee"
 2020/10/07 06:39:21 Terraform show |     resource_group_name     = "Default"
 2020/10/07 06:39:21 Terraform show |     resource_name           = "f5-bnpp-sch-vsi"
 2020/10/07 06:39:21 Terraform show |     resource_status         = "running"
 2020/10/07 06:39:21 Terraform show |     status                  = "running"
 2020/10/07 06:39:21 Terraform show |     tags                    = [
 2020/10/07 06:39:21 Terraform show |         "schematics:catalog-sample1-2338c1ba-e914-42",
 2020/10/07 06:39:21 Terraform show |     ]
 2020/10/07 06:39:21 Terraform show |     vcpu                    = [
 2020/10/07 06:39:21 Terraform show |         {
 2020/10/07 06:39:21 Terraform show |             architecture = "amd64"
 2020/10/07 06:39:21 Terraform show |             count        = 2
 2020/10/07 06:39:21 Terraform show |         },
 2020/10/07 06:39:21 Terraform show |     ]
 2020/10/07 06:39:21 Terraform show |     volume_attachments      = [
 2020/10/07 06:39:21 Terraform show |         {
 2020/10/07 06:39:21 Terraform show |             id          = "02k7-6b762731-6283-4dc8-9fc9-500c039b07e3"
 2020/10/07 06:39:21 Terraform show |             name        = "volume-attachment"
 2020/10/07 06:39:21 Terraform show |             volume_crn  = "crn:v1:bluemix:public:is:eu-fr2-1:a/322c285df3be4e90b19faabf6341f632::volume:r030-2fabf38b-4b28-4c59-bf37-90319eaf0b9e"
 2020/10/07 06:39:21 Terraform show |             volume_id   = "r030-2fabf38b-4b28-4c59-bf37-90319eaf0b9e"
 2020/10/07 06:39:21 Terraform show |             volume_name = "imaging-pasty-survivor-startup"
 2020/10/07 06:39:21 Terraform show |         },
 2020/10/07 06:39:21 Terraform show |     ]
 2020/10/07 06:39:21 Terraform show |     vpc                     = "r030-62a1cb21-9b36-4589-bdc4-a1fc1bbbcce7"
 2020/10/07 06:39:21 Terraform show |     zone                    = "eu-fr2-1"
 2020/10/07 06:39:21 Terraform show | 
 2020/10/07 06:39:21 Terraform show |     boot_volume {
 2020/10/07 06:39:21 Terraform show |         encryption = "crn:v1:bluemix:public:is:eu-fr2-1:a/322c285df3be4e90b19faabf6341f632::volume:r030-2fabf38b-4b28-4c59-bf37-90319eaf0b9e"
 2020/10/07 06:39:21 Terraform show |         iops       = 0
 2020/10/07 06:39:21 Terraform show |         name       = "volume-attachment"
 2020/10/07 06:39:21 Terraform show |         size       = 0
 2020/10/07 06:39:21 Terraform show |     }
 2020/10/07 06:39:21 Terraform show | 
 2020/10/07 06:39:21 Terraform show |     network_interfaces {
 2020/10/07 06:39:21 Terraform show |         id                   = "02k7-60aef1fd-5c48-4dcd-8574-18896f3369ff"
 2020/10/07 06:39:21 Terraform show |         name                 = "eth1"
 2020/10/07 06:39:21 Terraform show |         primary_ipv4_address = "10.247.2.17"
 2020/10/07 06:39:21 Terraform show |         security_groups      = [
 2020/10/07 06:39:21 Terraform show |             "r030-d9d66cec-2126-4f0a-bbaa-c0e10cdd35bc",
 2020/10/07 06:39:21 Terraform show |         ]
 2020/10/07 06:39:21 Terraform show |         subnet               = "02k7-c84c0c1a-4602-45df-8836-d0960bcacc69"
 2020/10/07 06:39:21 Terraform show |     }
 2020/10/07 06:39:21 Terraform show |     network_interfaces {
 2020/10/07 06:39:21 Terraform show |         id                   = "02k7-9619580d-22fc-4f67-916c-9c6de3dca4fc"
 2020/10/07 06:39:21 Terraform show |         name                 = "eth2"
 2020/10/07 06:39:21 Terraform show |         primary_ipv4_address = "10.247.3.18"
 2020/10/07 06:39:21 Terraform show |         security_groups      = [
 2020/10/07 06:39:21 Terraform show |             "r030-d9d66cec-2126-4f0a-bbaa-c0e10cdd35bc",
 2020/10/07 06:39:21 Terraform show |         ]
 2020/10/07 06:39:21 Terraform show |         subnet               = "02k7-0cd7c739-dbb9-4b2c-ba07-89ed3867aa6c"
 2020/10/07 06:39:21 Terraform show |     }
 2020/10/07 06:39:21 Terraform show | 
 2020/10/07 06:39:21 Terraform show |     primary_network_interface {
 2020/10/07 06:39:21 Terraform show |         id                   = "02k7-053ea3d4-6131-4049-9dec-54e0c756c085"
 2020/10/07 06:39:21 Terraform show |         name                 = "eth0"
 2020/10/07 06:39:21 Terraform show |         port_speed           = 0
 2020/10/07 06:39:21 Terraform show |         primary_ipv4_address = "10.247.0.17"
 2020/10/07 06:39:21 Terraform show |         security_groups      = [
 2020/10/07 06:39:21 Terraform show |             "r030-d9d66cec-2126-4f0a-bbaa-c0e10cdd35bc",
 2020/10/07 06:39:21 Terraform show |         ]
 2020/10/07 06:39:21 Terraform show |         subnet               = "02k7-71501954-6828-45da-a327-5b15f05e86d5"
 2020/10/07 06:39:21 Terraform show |     }
 2020/10/07 06:39:21 Terraform show | 
 2020/10/07 06:39:21 Terraform show |     timeouts {
 2020/10/07 06:39:21 Terraform show |         create = "10m"
 2020/10/07 06:39:21 Terraform show |         delete = "10m"
 2020/10/07 06:39:21 Terraform show |     }
 2020/10/07 06:39:21 Terraform show | }
 2020/10/07 06:39:21 Terraform show | 
 2020/10/07 06:39:21 Terraform show | # ibm_is_security_group.vnf_security_group:
 2020/10/07 06:39:21 Terraform show | resource "ibm_is_security_group" "vnf_security_group" {
 2020/10/07 06:39:21 Terraform show |     id                      = "r030-d9d66cec-2126-4f0a-bbaa-c0e10cdd35bc"
 2020/10/07 06:39:21 Terraform show |     name                    = "f5-schapi-security-group33"
 2020/10/07 06:39:21 Terraform show |     resource_controller_url = "https://cloud.ibm.com/vpc-ext/network/securityGroups"
 2020/10/07 06:39:21 Terraform show |     resource_crn            = "crn:v1:bluemix:public:is:eu-fr2:a/322c285df3be4e90b19faabf6341f632::security-group:r030-d9d66cec-2126-4f0a-bbaa-c0e10cdd35bc"
 2020/10/07 06:39:21 Terraform show |     resource_group          = "37bb11cc41794f52adebc2e2b0d583ee"
 2020/10/07 06:39:21 Terraform show |     resource_group_name     = "Default"
 2020/10/07 06:39:21 Terraform show |     resource_name           = "f5-schapi-security-group33"
 2020/10/07 06:39:21 Terraform show |     rules                   = []
 2020/10/07 06:39:21 Terraform show |     vpc                     = "r030-62a1cb21-9b36-4589-bdc4-a1fc1bbbcce7"
 2020/10/07 06:39:21 Terraform show | }
 2020/10/07 06:39:21 Terraform show | 
 2020/10/07 06:39:21 Terraform show | # ibm_is_security_group_rule.vnf_sg_allow_ssh:
 2020/10/07 06:39:21 Terraform show | resource "ibm_is_security_group_rule" "vnf_sg_allow_ssh" {
 2020/10/07 06:39:21 Terraform show |     direction  = "inbound"
 2020/10/07 06:39:21 Terraform show |     group      = "r030-d9d66cec-2126-4f0a-bbaa-c0e10cdd35bc"
 2020/10/07 06:39:21 Terraform show |     id         = "r030-d9d66cec-2126-4f0a-bbaa-c0e10cdd35bc.r030-589fee55-edef-4b92-925e-6889e6d0e1d1"
 2020/10/07 06:39:21 Terraform show |     ip_version = "ipv4"
 2020/10/07 06:39:21 Terraform show |     remote     = "0.0.0.0/0"
 2020/10/07 06:39:21 Terraform show |     rule_id    = "r030-589fee55-edef-4b92-925e-6889e6d0e1d1"
 2020/10/07 06:39:21 Terraform show | 
 2020/10/07 06:39:21 Terraform show |     tcp {
 2020/10/07 06:39:21 Terraform show |         port_max = 22
 2020/10/07 06:39:21 Terraform show |         port_min = 22
 2020/10/07 06:39:21 Terraform show |     }
 2020/10/07 06:39:21 Terraform show | }
 2020/10/07 06:39:21 Terraform show | 
 2020/10/07 06:39:21 Terraform show | # ibm_is_security_group_rule.vnf_sg_rule_in_all:
 2020/10/07 06:39:21 Terraform show | resource "ibm_is_security_group_rule" "vnf_sg_rule_in_all" {
 2020/10/07 06:39:21 Terraform show |     direction  = "inbound"
 2020/10/07 06:39:21 Terraform show |     group      = "r030-d9d66cec-2126-4f0a-bbaa-c0e10cdd35bc"
 2020/10/07 06:39:21 Terraform show |     id         = "r030-d9d66cec-2126-4f0a-bbaa-c0e10cdd35bc.r030-f43da5dd-0c59-4330-80e1-e19975b3fa41"
 2020/10/07 06:39:21 Terraform show |     ip_version = "ipv4"
 2020/10/07 06:39:21 Terraform show |     remote     = "0.0.0.0/0"
 2020/10/07 06:39:21 Terraform show |     rule_id    = "r030-f43da5dd-0c59-4330-80e1-e19975b3fa41"
 2020/10/07 06:39:21 Terraform show | }
 2020/10/07 06:39:21 Terraform show | 
 2020/10/07 06:39:21 Terraform show | # ibm_is_security_group_rule.vnf_sg_rule_out_all:
 2020/10/07 06:39:21 Terraform show | resource "ibm_is_security_group_rule" "vnf_sg_rule_out_all" {
 2020/10/07 06:39:21 Terraform show |     direction  = "outbound"
 2020/10/07 06:39:21 Terraform show |     group      = "r030-d9d66cec-2126-4f0a-bbaa-c0e10cdd35bc"
 2020/10/07 06:39:21 Terraform show |     id         = "r030-d9d66cec-2126-4f0a-bbaa-c0e10cdd35bc.r030-0a2826c7-829d-4d93-82d6-1c05688b6752"
 2020/10/07 06:39:21 Terraform show |     ip_version = "ipv4"
 2020/10/07 06:39:21 Terraform show |     remote     = "0.0.0.0/0"
 2020/10/07 06:39:21 Terraform show |     rule_id    = "r030-0a2826c7-829d-4d93-82d6-1c05688b6752"
 2020/10/07 06:39:21 Terraform show | }
 2020/10/07 06:39:21 Terraform show | 
 2020/10/07 06:39:21 Terraform show | 
 2020/10/07 06:39:21 Terraform show | Outputs:
 2020/10/07 06:39:21 Terraform show | 
 2020/10/07 06:39:21 Terraform show | map_instance = "r030-88b35711-82aa-45ae-b0e6-12785e7c2b55"
 2020/10/07 06:39:21 Command finished successfully.
 2020/10/07 06:39:23 Done with the workspace action

</code></pre>

7. Assign Floating-point IP to the F5 VSI created in Step 7.
<pre><code>Example:
curl --location --request POST 'https://eu-fr2.iaas.cloud.ibm.com/v1/floating_ips?version=2020-04-12&generation=2' \
--header "Authorization: Bearer $ACCESS_TOKEN" \
--header 'Content-Type: application/json' \
--header 'Cookie: __cfduid=dbd41efb9be799756effb44617e1a710a1594104587' \
--data-raw '{
	"name":"fip112",
	"target": {"id": "02k7-053ea3d4-6131-4049-9dec-54e0c756c085"}
}'
{"id":"r030-8315f620-97f5-4e0d-92dd-6f9cb6d5bc33","crn":"crn:v1:bluemix:public:is:eu-fr2-1:a/322c285df3be4e90b19faabf6341f632::floating-ip:r030-8315f620-97f5-4e0d-92dd-6f9cb6d5bc33","href":"https://eu-fr2.iaas.cloud.ibm.com/v1/floating_ips/r030-8315f620-97f5-4e0d-92dd-6f9cb6d5bc33","address":"158.231.95.240","name":"fip112","status":"available","created_at":"2020-10-07T06:51:19Z","zone":{"name":"eu-fr2-1","href":"https://eu-fr2.iaas.cloud.ibm.com/v1/regions/eu-fr2/zones/eu-fr2-1"},"target":{"resource_type":"network_interface","primary_ipv4_address":"10.247.0.17","name":"eth0","id":"02k7-053ea3d4-6131-4049-9dec-54e0c756c085","href":"https://eu-fr2.iaas.cloud.ibm.com/v1/instances/02k7_4719bd69-5c11-4b1f-b27e-06c870bb7da1/network_interfaces/02k7-053ea3d4-6131-4049-9dec-54e0c756c085"},"resource_group":{"id":"37bb11cc41794f52adebc2e2b0d583ee","href":"https://resource-controller.cloud.ibm.com/v2/resource_groups/37bb11cc41794f52adebc2e2b0d583ee","name":"Default"}}

</code></pre>
### 8.	Access Created F5 VSI using Floadting point ip (FIP)

    Terraform resources can be destroyed using below url command.

<pre><code>https://&lt;FIP></code></pre>

<pre><code>Example:

 https://158.231.95.240

</code></pre>

### 9.	Destroy resources

    Terraform resources can be destroyed using below curl command.

<pre><code>curl -X PUT https://eu-de.schematics.cloud.ibm.com/v1/workspaces/{id}/destroy -H "Authorization: Bearer &lt;access_token>" -H "refresh_token: &lt;refresh_token>"
</code></pre>

<pre><code>Example:

 curl -X PUT https://eu-de.schematics.cloud.ibm.com/v1/workspaces/catalog-sample1-2338c1ba-e914-42/destroy -H "Authorization: Bearer  $ACCESS_TOKEN" -H "refresh_token:$REFRESH_TOKEN"

{"activityid":"750b14843d92da0b48e8a225d599e2d0"}

</code></pre>

### 10.	Delete Workspace

    Workspace can be deleted using below curl command.

<pre><code>curl -X DELETE https://eu-de.schematics.cloud.ibm.com/v1/workspaces/{id} -H "Authorization: &lt;access_token>"</code></pre>

<pre><code>Example:

curl -X DELETE https://eu-de.schematics.cloud.ibm.com/v1/workspaces/catalog-sample1-2338c1ba-e914-42 -H "Authorization: Bearer $ACCESS_TOKEN" | jq
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100     2    0     2    0     0      0      0 --:--:--  0:00:03 --:--:--     0

</code></pre>

