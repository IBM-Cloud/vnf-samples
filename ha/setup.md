## IBM Cloud VNF High Availability Setup

This document explains some of the basic steps needed to configure IBM VPC Virtual Network Function (VNFs) for HA. The feature is currently allow-list only and only available in the us-east region. Supported use cases include:
* Active / Active
* Active / Passive

# Configure the VPC Resources

1) Create a VPC.
2) Create 1 subnet for the VNF management traffic interface. This can be shared between multiple VNF's to support clustering, etc.
3) Create 1 subnet that will be shared between the VNF's data traffic interface and the Network Load Balancer (NLB).
4) Create any additional subnet's needed for the VSI workload's that will be routed through the NLB/VNF's.
5) Grant a service authorization for this IBM Cloud Account to allow the NLB to modify custom routes if an NLB failover occurs. See Images below for guidance. This should only be needed once per Account.

More details on service to service authorization can be found [here](https://cloud.ibm.com/docs/account?topic=account-serviceauth&interface=ui#create-auth)

![](/images/grant-service-auth1.png)
![](/images/grant-service-auth2.png)

# Deploy the VNF

There are multiple IBM Cloud VNF catalog offerings. Vendor specific details will be provided at a later date.

1) Ensure the VNF data interface is on the same shared subnet as the NLB we will provision later.
2) Ensure the VNF data interface (shared subnet with NLB) has "Allow IP Spoofing" enabled. You can enable through the VPC VSI UI -> Network Interfaces 
3) The VNF configuration will need to enable "health checks" from the NLB. HTTP or TCP is supported. See the section "NLB HA failovers and custom routes" below for details on retrieving the NLB IP's. 

# Deploy the NLB

1) Ensure your IBM Cloud account is allow listed to the NLB "Route Mode" support available in us-east.
2) Currently this is only available via the [IBM RIAS REST API's](https://pages.github.ibm.com/riaas/api-spec/spec_aspirational/#/Load%20balancers/create_load_balancer) with the "Route Mode" not publicly documented. 
3) Ensure you have an IBM Cloud API Key which you can use to retrieve the RIAS token and inject in the REST call below. You can use something like:

```
#!/bin/bash
token_endpoint="https://iam.cloud.ibm.com/identity/token"

apikey="<redacted>"

ACCESS_TOKEN=$(curl -u "bx:bx" -k -v -X POST \
        --header "Content-Type: application/x-www-form-urlencoded" \
        --header "Accept: application/json" \
        -d "grant_type=urn:ibm:params:oauth:grant-type:apikey&response_type=cloud_iam&apikey=$apikey" \
        $token_endpoint | python -c 'import sys, json; print(json.load(sys.stdin)["access_token"])')

export RIAS_TOKEN=$ACCESS_TOKEN
echo export RIAS_TOKEN="\"$RIAS_TOKEN\""
```

4) REST Details:
* Specify new "route_mode":true to enable "Route Mode"
* Specify the shared VNF "subnets" from the instances above.
* Specify the VNF VSI instance id in the "pools" -> "members"
* Remove "listeners" -> "pool" from the payload.

Example Payload to create an NLB in "Route Mode" with 2 VNF VSI members with a TCP health check on port 80.

```
{
  "name": "my-nlb-for-vnf",
  "is_public": false,
  "route_mode": true,
  "profile": {
    "name": "network-fixed"
  },
  "listeners": [
    {
      "default_pool": {
        "name": "pool-1"
      },
      "port_min": 1,
      "port_max": 65535,
      "protocol": "tcp"
    }
  ],
  "pools": [
     {
      "algorithm": "round_robin",
      "health_monitor": {
        "delay": 5,
        "max_retries": 2,
        "timeout": 2,
        "type": "http",
        "url_path": "/"
      },
      "name": "pool-1",
      "protocol": "tcp",
      "members": [
        {
          "target" : {
            "id": "0767_ac9a0f33-0471-427a-9f32-f1f4c2184499"
            },
          "port": 80,
          "weight": 50
        },
        {
          "target" : {
            "id": "0726_047e1bea-6974-4315-a404-ba3e4e68b998"
            },
          "port": 80,
          "weight": 50
        }
      ]
    }
  ],
  "subnets": [
    {
      "id": "0767-de42438f-baa9-4b82-a67e-416a2cd8ac99"
    }
  ],
  "resource_group": {"id":"deb5430d845940ff94832fef535ab899"}
}
```

5) Execute the REST call. You can use something like:

```
#!/bin/bash
source ./get_rias_token.sh

# Prod Endpoints: https://cloud.ibm.com/docs/vpc?topic=vpc-service-endpoints-for-vpc#cloud-service-endpoints
export RIAS_EP="https://us-east.iaas.cloud.ibm.com"
export HOSTNAME="us-east.iaas.cloud.ibm.com"
export HOST="X-Original-Host"

curl -k -s -v \
        -H "Authorization:Bearer $RIAS_TOKEN" \
        -H "$HOST: $HOSTNAME" \
        --data "@nlb_create_vnf_payload.txt" \
        -X POST $RIAS_EP/v1/load_balancers?generation=2
```

6) Ensure the NLB's Pool includes the VNF VSI members and the health check is "Passed".

# Configure Security Groups

The VNF data network interface is attached to a VPC Security Group. Ensure the Security Group has Inbound rules that allow traffic on the health port setup between the NLB and the VNF. For example, if the health check is setup for TCP on Port 80 (HTTP) then create an "Inbound rule" under that Security Group.

# Configure Custom Routes

Custom routes will be needed to ensure ingress data traffic is routed through the NLB on it's way to the VNF and target destination. In some cases custom routes may also be needed to ensure egress traffic is returned to the original client source.

Let's consider the following example setup for a Palo Alto VM-Series:

![](/images/vnf-palo-flow-diagram.png)

An Ingress custom route was created to ensure client (10.240.1.5) data packets destined for the target (10.240.66.4) "hop" through the NLB setup in "Route Mode". In this Active / Active example an egress route is also needed to ensure data traffic from the target will "hop" through the NLB on the return trip. In this example the client is in a different zone than the target.

More information on custom routes can be found [here](https://cloud.ibm.com/docs/vpc?topic=vpc-about-custom-routes)
  
# NLB failovers and custom routes

* The NLB is deployed as an active / passive cluster. Each node has a distinct IP. The active IP must be used in the custom routes that are created. You can use an `nslookup` on the NLB hostname to determine which IP is the primary for use in your route config.
* The VNF's must also be configured to allow traffic from both the active and passive NLB nodes. This is needed for the health check. The IP's can be retrieved from the GET REST API call:
 
```
curl -k -s -v \
        -H "Authorization:Bearer $RIAS_TOKEN" \
        -H "$HOST: $HOSTNAME" \
        -X GET $RIAS_EP/v1/load_balancers?generation=2
```



