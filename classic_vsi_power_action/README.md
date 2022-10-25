# Script to power virtual Server Instances on/off in an automated scheduled manner using IBM Cloud Code Engine

When you provision a virtual server instance that supports the suspend billing feature,
the usage times are calculated per second, for both the in-use time and suspended time
of your virtual server instance. Even if you never initiate the suspend billing feature
by powering off your instance, the billing is calculated per second of the instance's
lifecycle.

This Classic VSI Power action one-click deployment uses `Code Engine Service` which is
Serverless Function.  As part of deployment, code will be deployed in Code Engine to
execute the scheduled power actions (ON/OFF) in order to suspend the billing.

Upon the code execution in this repository will create `IBM Cloud Code Engine` project,
jobs, container registry image and cron executions. These detail can be viewed/edited
through UI/CLI after successful execution in `cloud.ibm.com`.

## Accesses to resources

- Code Engine Service.
- Container Registry.
- Classic Infrastructure.
- Classic Virtual Server instance actions: Power ON/OFF.

## Prerequisites

- Clone the repo <https://github.com/IBM-Cloud/vnf-samples>
- IBM Cloud cli <https://cloud.ibm.com/docs/cli?topic=cli-getting-started>
- Code Engine Plugin. Install it using command `ibmcloud plugin install code-engine`

## Input to the script

Below are the input to the script. These inputs should be specified in
`vsi_power_action.env` file.

- `IBMCLOUD_API_KEY` - IBM Cloud Account API Key for creating Code Engine Project.
- `IBMCLOUD_REGION` - IBM Cloud region where Code Engine should be created. Example: `"us-south"`.
- `IBMCLOUD_RESOURCE_GROUP` - IBM Cloud Resource Group (if it default, then the
input should be Default)
- `IBMCLOUD_PROJECT_NAME` - IBM Cloud Code Engine Project Name.
- `CLASSIC_VSI_ACCOUNT_API_KEY` - Classic VSI Account API Key.  This is the account
where all the VSIs should be scheduled for power on/off.
- `CLASSIC_VSI_ACCOUNT_USER_NAME` - Classic VSI Account User name.
- `CLASSIC_VSI_LIST_FILE` - Classic VSI list file `vsi_id.txt`. This file should
contain the list of VSI IDs which are needed to be scheduled for power on/off.
Example for having the VSI IDs in the file

    ```text
    VSI_1=XXXX8695
    VSI_2=XXXXX083
    ```

- `POWER_ON_SCHEDULE` - Power ON Schedule in UTC format (it should be in the
format of Cron job schedule). Ex. If you want to power ON VSI at 9AM every
weekdays (Mon – Fri), then `POWER_ON_SCHEDULE="00 09 ** 1-5"`

- `POWER_OFF_SCHEDULE` - Power OFF Schedule in UTC format (it should be in the
format of Cron job schedule). Ex. If you want to power off VSI at 6 PM every
weekdays (Mon-Fri), then `POWER_OFF_SCHEDULE="00 18 ** 1-5"`

- Example for `vsi_power_action.env` file.

    ```env
    export IBMCLOUD_API_KEY="xxxx"
    export IBMCLOUD_REGION="us-south"
    export IBMCLOUD_RESOURCE_GROUP="Demo Related"
    export IBMCLOUD_PROJECT_NAME="power-on-and-off-demo"
    export CLASSIC_VSI_ACCOUNT_API_KEY="xxxx"
    export CLASSIC_VSI_ACCOUNT_USER_NAME="xxxx@ibm.com"
    export CLASSIC_VSI_LIST_FILE="vsi_id.txt"
    export POWER_ON_SCHEDULE="00 09 * * 1-5"
    export POWER_OFF_SCHEDULE="00 18 * * 1-5"
    ```

## Script execution

Execute the file `vsi_power_action.sh`

```bash
sh vsi_power_action.sh
```

## References

- [Using IBM Cloud Code Engine to turn virtual server instances on/off in an automated scheduled manner](https://www.ibm.com/cloud/blog/using-ibm-cloud-code-engine-to-turn-virtual-server-instances-on/off-in-an-automated/scheduled-manner)

- [Classic VSI suspend billing](https://cloud.ibm.com/docs/virtual-servers?topic=virtual-servers-requirements)
