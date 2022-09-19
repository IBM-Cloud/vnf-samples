# ansible-app-deploy-roks-local
To run locally in your mac to configure a webapp in a ROKS cluster


### Steps:  

1. Login to IBM Cloud.   

2. Download Cluster :   

```
malark@Malars-MacBook-Pro ansible-app-deploy-roks-local % ibmcloud ks cluster config -c cluster-think-demo --admin  
OK
The configuration for cluster-think-demo was downloaded successfully.

Added context for cluster-think-demo to the current kubeconfig file.
You can now execute 'kubectl' commands against your cluster. For example, run 'kubectl get nodes'.
If you are accessing the cluster for the first time, 'kubectl' commands might fail for a few seconds while RBAC synchronizes.

```

3. Run ansible-playbook:  

```
malark@Malars-MacBook-Pro ansible-app-deploy-roks-local % ansible-playbook site.yml           
[WARNING]: No inventory was parsed, only implicit localhost is available
[WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not match 'all'

PLAY [localhost] *******************************************************************************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************************************************************
ok: [localhost]

PLAY [apply common configuration to all nodes] *************************************************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************************************************************
ok: [localhost]

TASK [web : Create Web Application] ************************************************************************************************************************************************************************
changed: [localhost]

TASK [loadbalancer : Create alb web service] ***************************************************************************************************************************************************************
changed: [localhost]

PLAY RECAP *************************************************************************************************************************************************************************************************
localhost                  : ok=4    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

4. List all pods created:   

```
malark@Malars-MacBook-Pro ansible-app-deploy-roks-local % kubectl get pods -n default         
NAME                                   READY   STATUS    RESTARTS   AGE
app-lb-deployment-788d8b8454-4mxbj     1/1     Running   0          8s
app-lb-deployment-788d8b8454-6m49z     1/1     Running   0          8s
app-lb-deployment-788d8b8454-w6gmt     1/1     Running   0          8s
```

5. List all services: 

```
malark@Malars-MacBook-Pro ansible-app-deploy-roks-local % kubectl get svc            
NAME                           TYPE           CLUSTER-IP       EXTERNAL-IP                            PORT(S)          AGE
app-lb-service                 LoadBalancer   172.21.13.5      ad5b428b-us-south.lb.appdomain.cloud   8000:32321/TCP   55s

kubernetes                     ClusterIP      172.21.0.1       <none>                                 443/TCP          4d8h
openshift                      ExternalName   <none>           kubernetes.default.svc.cluster.local   <none>           4d8h
openshift-apiserver            ClusterIP      172.21.88.80     <none>                                 443/TCP          4d8h
openshift-oauth-apiserver      ClusterIP      172.21.13.39     <none>                                 443/TCP          4d8h
```

6. Run the application:  

```
malark@Malars-MacBook-Pro ansible-app-deploy-roks-local % curl ad5b428b-us-south.lb.appdomain.cloud:8000
Hello World! Server is 172.17.25.223%     
```
