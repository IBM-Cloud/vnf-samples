
**Solution Use case**
### Automating 3 tier web application deployment with NLB on IBM Cloud Kubernetes Service Classic. Access the application in VPC using Strongswan VPN gateway. 
### Configure Strongswan VPN between VPC and Classic

![VPN with Strongswan](images/VPC_Classic.png)

To run locally in your mac to configure a webapp in a IKS cluster

Before executing the ansible playbook:

1.    Add account apikey in vpc_classic.tf file
2.    Add Cloudant apikey in roles/web/tasks/main.yml
3.    Add RIAS API Key in iks_think_demo.sh

export RIAS_API_KEY=""


### Steps:  

1. Run ansible-playbook, terraform using shell script:  

```
malark@Malars-MacBook-Pro recommender-engine-hybrid-cloud-automation % sh iks_think_demo.sh 
...
Log in to the IBM Cloud CLI by running 'ibmcloud login'.

Downloaded Kube Config

PLAY [localhost] *******************************************************************************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************************************************************
[WARNING]: Platform darwin on host localhost is using the discovered Python interpreter at /usr/bin/python3, but future installation of another Python interpreter could change the meaning of that path.
See https://docs.ansible.com/ansible-core/2.13/reference_appendices/interpreter_discovery.html for more information.
ok: [localhost]

PLAY [apply common configuration to all nodes] *************************************************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************************************************************
ok: [localhost]

TASK [web : Create Web Application] ************************************************************************************************************************************************************************
ok: [localhost]

TASK [loadbalancer : Create nlb dal10 web service] *********************************************************************************************************************************************************
ok: [localhost]

TASK [loadbalancer : Create nlb dal12 web service] *********************************************************************************************************************************************************
ok: [localhost]

TASK [loadbalancer : Create nlb dal13 web service] *********************************************************************************************************************************************************
ok: [localhost]

PLAY RECAP *************************************************************************************************************************************************************************************************
localhost                  : ok=6    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

PLAY [configure vpn gateway in classic server] *************************************************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************************************************************
ok: [classicserver04.VNF-Experiments-Account.cloud]

TASK [vpn : Validate PSK] **********************************************************************************************************************************************************************************
ok: [classicserver04.VNF-Experiments-Account.cloud] => (item={'local': {'id': '169.38.71.122', 'networks': '10.163.49.64/26', 'public': '%defaultroute'}, 'name': 'classic-vpc-test', 'psk': 'secret', 'remote': {'networks': '192.168.0.0/24', 'public': '52.116.143.198'}}) => {
    "ansible_loop_var": "item",
    "changed": false,
    "item": {
        "local": {
            "id": "169.38.71.122",
            "networks": "10.163.49.64/26",
            "public": "%defaultroute"
        },
        "name": "classic-vpc-test",
        "psk": "secret",
        "remote": {
            "networks": "192.168.0.0/24",
            "public": "52.116.143.198"
        }
    },
    "msg": "All assertions passed"
}

TASK [vpn : Upgrade all packages to the latest version] ****************************************************************************************************************************************************
ok: [classicserver04.VNF-Experiments-Account.cloud]

TASK [vpn : Update all packages to the latest version] *****************************************************************************************************************************************************
ok: [classicserver04.VNF-Experiments-Account.cloud]

TASK [vpn : Run the equivalent of "apt-get update" as a separate step] *************************************************************************************************************************************
changed: [classicserver04.VNF-Experiments-Account.cloud]

TASK [vpn : Install strongswan] ****************************************************************************************************************************************************************************
changed: [classicserver04.VNF-Experiments-Account.cloud] => (item=strongswan)
changed: [classicserver04.VNF-Experiments-Account.cloud] => (item=strongswan-pki)
changed: [classicserver04.VNF-Experiments-Account.cloud] => (item=libcharon-extra-plugins)

TASK [vpn : IPSec must be running] *************************************************************************************************************************************************************************
ok: [classicserver04.VNF-Experiments-Account.cloud]

TASK [vpn : Set required sysctl settings] ******************************************************************************************************************************************************************
changed: [classicserver04.VNF-Experiments-Account.cloud] => (item={'key': 'net.ipv4.ip_forward', 'value': 1})

TASK [vpn : Init connections variable] *********************************************************************************************************************************************************************
ok: [classicserver04.VNF-Experiments-Account.cloud]

TASK [vpn : Apply connection defaults] *********************************************************************************************************************************************************************
ok: [classicserver04.VNF-Experiments-Account.cloud] => (item={'local': {'id': '169.38.71.122', 'networks': '10.163.49.64/26', 'public': '%defaultroute'}, 'name': 'classic-vpc-test', 'psk': 'secret', 'remote': {'networks': '192.168.0.0/24', 'public': '52.116.143.198'}})

TASK [vpn : Create IPsec config directory] *****************************************************************************************************************************************************************
ok: [classicserver04.VNF-Experiments-Account.cloud]

TASK [vpn : Include IPsec configuration] *******************************************************************************************************************************************************************
changed: [classicserver04.VNF-Experiments-Account.cloud]

TASK [vpn : Include IPsec secrets] *************************************************************************************************************************************************************************
changed: [classicserver04.VNF-Experiments-Account.cloud]

TASK [vpn : Copy IPsec configuration] **********************************************************************************************************************************************************************
changed: [classicserver04.VNF-Experiments-Account.cloud]

TASK [vpn : Copy IPsec secrets] ****************************************************************************************************************************************************************************
changed: [classicserver04.VNF-Experiments-Account.cloud]

RUNNING HANDLER [vpn : restart ipsec] **********************************************************************************************************************************************************************
changed: [classicserver04.VNF-Experiments-Account.cloud]

RUNNING HANDLER [vpn : reload ipsec] ***********************************************************************************************************************************************************************
changed: [classicserver04.VNF-Experiments-Account.cloud]

PLAY RECAP *************************************************************************************************************************************************************************************************
classicserver04.VNF-Experiments-Account.cloud : ok=17   changed=9    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   


```

4. Check application:

```
malark@Malars-MacBook-Pro tasks % kubectl get deployments                         
NAME                READY   UP-TO-DATE   AVAILABLE   AGE
app-lb-deployment   3/3     3            3           13d
malark@Malars-MacBook-Pro tasks % kubectl get pods
NAME                                 READY   STATUS        RESTARTS   AGE

app-lb-deployment-7456497dc5-2p44k   1/1     Running       0          12s
app-lb-deployment-7456497dc5-g8vjj   1/1     Running       0          15s
app-lb-deployment-7456497dc5-z892c   1/1     Running       0          18s
```

5. Check services:
```
malark@Malars-MacBook-Pro recommender-engine-hybrid-cloud-automation % kubectl get svc                                                       
NAME                           TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)          AGE
flasknode-vpc-nlb-us-south-1   LoadBalancer   172.21.209.35   10.177.71.98    8000:31501/TCP   168m
flasknode-vpc-nlb-us-south-2   LoadBalancer   172.21.178.19   10.74.203.131   8000:30598/TCP   168m
flasknode-vpc-nlb-us-south-3   LoadBalancer   172.21.71.30    10.187.127.13   8000:32023/TCP   168m
kubernetes                     ClusterIP      172.21.0.1      <none>          443/TCP          105d

```

6. Login to a classic VSI and invoke web application using NLB:

```
root@classicserver04:~# curl http://10.177.71.98:8000 
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Show all employees</title>
</head>
<body>
<h3>List of all employees</h3>

<table border="1">
    <tr>
        <th align="center">Employee Id</th>
		<th align="center">Name</th>
    </tr>
    
    <tr>
        <td align="center">444</td>
        <td align="center">Sita</td>
	</tr>
    
    <tr>
        <td align="center">234</td>
        <td align="center">IBM</td>
	</tr>
    
    <tr>
        <td align="center">123</td>
        <td align="center">Network</td>
	</tr>
    
</table>root@classicserver04:~# exit
logout

```

