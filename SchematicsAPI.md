## Schematics API

This document provides the steps to perform IBM Schematics tasks like creating Schematics workspace, performing plan, apply, destroy commands using Schematics API Curl Commands.

1.	Create tokens:
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

2.  Export the access_token and refresh_token obtained in step 1 as environment variables as ACCESS_TOKEN and REFRESH_TOKEN respectively.

<pre><code>export ACCESS_TOKEN=&lt;access_token>
export REFRESH_TOKEN=&lt;refresh_token>
</code></pre>


3.  Create workspace.

    Workspace using exisiting github repo url can be created using below sample:

<pre><code>curl --request POST --url https://schematics.cloud.ibm.com/v1/workspaces -H "Authorization: Bearer &lt;access_token>" -d '{"name":"<workspace_name>","type": ["terraform_v0.12"],"description": "<workspace_description>","resource_group": "<resource_group_ID>","tags": [],"template_repo": {"url": "<source_repo_url>"},"template_data": [{"folder": ".","type": "terraform_v0.12","variablestore": [{"name": "variable_name1","value": "variable_value1"},{"name": "variable_name2","value": "variable_value2"}]}]}'
</code></pre>

<pre><code>
Example:

curl --request POST --url https://schematics.cloud.ibm.com/v1/workspaces -H "Authorization: Bearer $ACCESS_TOKEN" -d '{"name":"catalog-sample1","type": ["terraform_v0.12"],"description": "Test schematics", "resource_group": "1abd89a13bff450c9676c833bfcdf746", "tags": [], "template_repo": {"url": "https://github.com/IBM-Cloud/vnf-samples/tree/master/catalog_img_vsi_sample"},"template_data": [{"folder": ".","type": "terraform_v0.12","variablestore": [{"name": "zone","value": "us-south-3"},
{"name": "vpc_name","value": "ckp-test"}, {"name": "subnet_id", "value": "0737-ccb34e29-dfaf-4774-8903-73525b815826"}, {"name": "ssh_key_name", "value": "test-key"}, {"name": "vnf_vpc_image_id", "value": "r006-ed3f775f-ad7e-4e37-ae62-7199b4988b00"}, {"name": "vnf_instance_name", "value": "ubuntu18-04-vsi2"}, {"name": "vnf_profile", "value": "bx2-2x8"}, {"name": "region", "value": "us-south"}, {"name": "resource_group", "value": "Checkpoint Offering"}, {"name": "vnf_security_group", "value": "ubuntu-security-group3"}]}]}' | jq
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  3555    0  2652  100   903    376    128  0:00:07  0:00:07 --:--:--   735
{
  "id": "catalog-sample1-376ad599-b556-4d",
  "name": "catalog-sample1",
  "crn": "crn:v1:bluemix:public:schematics:us-south:a/6991a6797b7b4754947b081d8dedc6e7:9cca97ea-ac19-46da-ab50-195fe2169663:workspace:catalog-sample1-376ad599-b556-4d",
  "type": [
    "terraform_v0.12"
  ],
  "description": "Test schematics",
  "resource_group": "Checkpoint Offering",
  "location": "us-east",
  "tags": [],
  "created_at": "2020-06-26T10:42:06.60346817Z",
  "created_by": "test-user@in.ibm.com",
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
    "full_url": "https://github.com/IBM-Cloud/vnf-samples/tree/master/catalog_img_vsi_sample",
    "has_uploadedgitrepotar": false
  },
  "template_data": [
    {
      "id": "catalog_img_vsi_sample-310844ba-09ba-40",
      "folder": "catalog_img_vsi_sample",
      "type": "terraform_v0.12",
      "values_url": "https://schematics.cloud.ibm.com/v1/workspaces/catalog-sample1-376ad599-b556-4d/template_data/catalog_img_vsi_sample-310844ba-09ba-40/values",
      "values": "",
      "variablestore": [
        {
          "name": "zone",
          "secure": false,
          "value": "us-south-3",
          "type": "",
          "description": ""
        },
        {
          "name": "vpc_name",
          "secure": false,
          "value": "ckp-test",
          "type": "",
          "description": ""
        },
        {
          "name": "subnet_id",
          "secure": false,
          "value": "0737-ccb34e29-dfaf-4774-8903-73525b815826",
          "type": "",
          "description": ""
        },
        {
          "name": "ssh_key_name",
          "secure": false,
          "value": "test-key",
          "type": "",
          "description": ""
        },
        {
          "name": "vnf_vpc_image_id",
          "secure": false,
          "value": "r006-ed3f775f-ad7e-4e37-ae62-7199b4988b00",
          "type": "",
          "description": ""
        },
        {
          "name": "vnf_instance_name",
          "secure": false,
          "value": "ubuntu18-04-vsi2",
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
          "value": "us-south",
          "type": "",
          "description": ""
        },
        {
          "name": "resource_group",
          "secure": false,
          "value": "Checkpoint Offering",
          "type": "",
          "description": ""
        },
        {
          "name": "vnf_security_group",
          "secure": false,
          "value": "ubuntu-security-group3",
          "type": "",
          "description": ""
        }
      ],
      "has_githubtoken": false
    }
  ],
  "runtime_data": [
    {
      "id": "catalog_img_vsi_sample-310844ba-09ba-40",
      "engine_name": "terraform",
      "engine_version": "v0.12.20",
      "state_store_url": "https://schematics.cloud.ibm.com/v1/workspaces/catalog-sample1-376ad599-b556-4d/runtime_data/catalog_img_vsi_sample-310844ba-09ba-40/state_store",
      "log_store_url": "https://schematics.cloud.ibm.com/v1/workspaces/catalog-sample1-376ad599-b556-4d/runtime_data/catalog_img_vsi_sample-310844ba-09ba-40/log_store"
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

<pre><code>curl -X POST https://schematics.cloud.ibm.com/v1/workspaces/{id}/plan -H "Authorization: Bearer &lt;access_token>" -H "refresh_token: &lt;refresh_token>"
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

5.	Terraform Apply
    
    Terraform Apply can be performed using below curl command.

<pre><code>curl -X PUT https://schematics.cloud.ibm.com/v1/workspaces/{id}/apply -H "Authorization: Bearer &lt;access_token>" -H "refresh_token: &lt;refresh_token>"
</code></pre>

<pre><code>Example:

curl -X PUT https://schematics.cloud.ibm.com/v1/workspaces/catalog-sample1-376ad599-b556-4d/apply -H "Authorization: $ACCESS_TOKEN" -H "refresh_token: $REFRESH_TOKEN" | jq
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100    49  100    49    0     0     38      0  0:00:01  0:00:01 --:--:--    38
{
  "activityid": "c77896ecd2bf098fbab29ae409caa033"
}
</code></pre>

6.	Destroy resources

    Terraform resources can be destroyed using below curl command.

<pre><code>curl -X PUT https://schematics.cloud.ibm.com/v1/workspaces/{id}/destroy -H "Authorization: Bearer &lt;access_token>" -H "refresh_token: &lt;refresh_token>"
</code></pre>

<pre><code>Example:

curl -X PUT https://schematics.cloud.ibm.com/v1/workspaces/catalog-sample1-376ad599-b556-4d/destroy -H "Authorization: Bearer $ACCESS_TOKEN" -H "refresh_token: $REFRESH_TOKEN" | jq
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100    49  100    49    0     0     30      0  0:00:01  0:00:01 --:--:--    30
{
  "activityid": "27d6948cf38fbd57d30c0c8f746a17b0"
}
</code></pre>

7.	Delete Workspace

    Workspace can be deleted using below curl command.

<pre><code>curl -X DELETE https://schematics.cloud.ibm.com/v1/workspaces/{id} -H "Authorization: &lt;access_token>"</code></pre>

<pre><code>Example:

curl -X DELETE https://schematics.cloud.ibm.com/v1/workspaces/catalog-sample1-376ad599-b556-4d -H "Authorization: Bearer $ACCESS_TOKEN" | jq
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100     2    0     2    0     0      0      0 --:--:--  0:00:03 --:--:--     0
""
</code></pre>



**Other Curl Commands can be referred from the URL https://cloud.ibm.com/apidocs/schematics**

8. **Import states between COS and Workspace:**  

The state files stored in COS can be imported in a schematics workspace and maintained by Schematics using CLI as shown below:  

a) ibmcloud logout  

b) ibmcloud login -a https://cloud.ibm.com -apikey <<eeZ......>>  

c) ibmcloud target -g Default   

Targeted resource group Default.   

d) ibmcloud plugin install schematics  

e) Download the state file <<global.tfstate>> from COS bucket to your local system.  

f) ibmcloud schematics workspace new --file global.json --state global.tfstate   

**Contents of global.json:**  
<pre><code>
{
"name":"import-workspace-test",
"type": ["terraform_v0.12"],
"description": "Test import state in workspace", 
"resource_group": "1abd89a13bff450c9676c833bfcdf746", 
"tags": [], 
"template_repo": {"url": "https://github.com/MalarvizhiK/cos-terraforming"},
"template_data": [{"folder": ".","type": "terraform_v0.12","variablestore": [{"name": "vpc_name","value": "test-malar-vpc"},
{"name": "resource_group","value": "Default"},
{"name": "region","value": "us-south"}]}]
}

</code></pre>    

You can get the resource_group id from CLI command and specify it in  **global.json**, 

<pre><code>
Malars-MacBook-Pro-2:Downloads malark$ ibmcloud resource groups 
Retrieving all resource groups under account VNF Experiments Account as K.MALARVIZHI@IN.IBM.COM...
OK
Name                  ID                                 Default Group   State   
Checkpoint Offering   1abd89a13bff450c9676c833bfcdf746   false           ACTIVE   
Image Scan            3009466bfc3d4c54975ec8dc86303a69   false           ACTIVE   
Default               42ee88169dd7406584925447bc5b25eb   true            ACTIVE   
Transit Gateway       730d7583379f4e8db6585cb562f756b2   false           ACTIVE   
F5 Offering           d9f8a62471f84a0cbb48e4cf4809fbd2   false           ACTIVE   
PDNS Testing          f50bd83e28324e3183dbe92238e93194   false           ACTIVE   
</code></pre>  

Result:    

<pre><code>
Malars-MacBook-Pro-2:Downloads malark$ ibmcloud schematics workspace new --file global.json --state global.tfstate 
                   
Creation Time   Thu Jul 2 08:49:14   
Description     Test import state in workspace   
Frozen          false   
ID              import-workspace-test-d79333d9-1a61-40   
Name            import-workspace-test   
Status          DRAFT   
                   
Template Variables for: 579a27dc-749c-4c
Name             Value   
vpc_name         test-malar-vpc   
resource_group   Default   
region           us-south   
                 
OK
</code></pre>       

9.  **Import states between  different Schematics Workspaces :**     

The state file from a schematics workspace should be downloaded first and imported to another workspace. This can be achieved using Schematics CLI as shown below:    

a) ibmcloud logout    

b) ibmcloud login -a https://cloud.ibm.com -apikey <<eeZ......>>    

c) ibmcloud target -g Default      

Targeted resource group Default.     

d) ibmcloud plugin install schematics       

e) Get the Workspace id from UI. With this workspace id, fetch the Template id from the CLI command.   
<pre><code>  
ibmcloud schematics workspace get --id import-workspace-test-d79333d9-1a61-40 --json  
</code></pre>  

This will ouput json. Look for Template id:  

<pre><code>
"template_data": [
    {
      "id": "579a27dc-749c-4c",
....
}  

</code></pre>  

Right now, there is only 1 template id, which is the id of github repo url. In future, there are plans to support multiple github repos in a single workspace.   

f) Download the state file from a schematics workspace to your local system.      

<pre><code>  
ibmcloud schematics state pull --id "import-workspace-test-d79333d9-1a61-40" --template "579a27dc-749c-4c"
</code></pre>  

This will ouput json. Copy the json and save it a file "state.json".   

g) Import the state files to a Schematics workspace.   

<pre><code>
 ibmcloud schematics workspace new --file global.json --state state.json
</code></pre>

Result:       
  
<pre><code>  
Malars-MacBook-Pro-2:Downloads malark$ ibmcloud schematics workspace new --file global.json --state state.json
                   
Creation Time   Thu Jul 2 10:32:58   
Description     Test state files between workspaces   
Frozen          false   
ID              import-workspace-test-2-df746802-3eb8-4f   
Name            import-workspace-test-2   
Status          DRAFT   
                   
Template Variables for: f0e4ce7e-3d47-4f
Name             Value   
vpc_name         test-malar-vpc   
resource_group   Default   
region           us-south   
                 
OK

</code></pre>

