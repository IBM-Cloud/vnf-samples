#!/bin/bash
ibmcloud login -a cloud.ibm.com --apikey $RIAS_API_KEY -r us-south

echo "Logged in to Cloud"

ibmcloud ks cluster config -c cluster-think-demo --admin

echo  "Downloaded Kube Config"

ansible-playbook site.yml

echo -e "Deploying Application and ALB.. Please wait for sometime..\n\n"

domain=`kubectl get svc | awk 'NR == 2 {print $4}'`

sleep 300

while [ "$domain" == "<pending>" ]
do
    echo -e "Please wait for sometime..\n"
    sleep 30
    domain=`kubectl get svc | awk 'NR == 2 {print $4}'`
done

echo "kubectl get pods -n default"

kubectl get pods -n default

echo "kubectl get svc"

kubectl get svc

python3 think_demo_tvar_create.py $domain

echo "Running terraform to deploy VPN Gateways"

terraform init

terraform apply --var-file="terraform.tfvars" -auto-approve 
