#!/bin/bash

export RIAS_API_KEY=""

ibmcloud login -a cloud.ibm.com --apikey $RIAS_API_KEY -r us-south

echo "Logged in to Cloud"

ibmcloud ks cluster config -c mycluster-dal10-b3c.4x16 --admin

echo  "Downloaded Kube Config"

ansible-playbook  --private-key ~/.ssh/id_rsa  pre_install.yml 

sleep 600

ansible-playbook site.yml 

echo -e "Deploying Application and NLB.. Please wait for sometime..\n\n"

sleep 30

echo "kubectl get pods"
kubectl get pods

echo "kubectl get svc"
kubectl get svc

kubectl get svc > svc_result.txt 

echo 'vpc_crn="crn:v1:bluemix:public:is:us-south:a/6991a6797b7b4754947b081d8dedc6e7::vpc:r006-8b78baeb-4e3c-481f-bdee-a75ec12bbd6f"' > terraform.tfvars

echo 'region="us-south"' >> terraform.tfvars

echo 'generation=2' >> terraform.tfvars

export address1=`cat svc_result.txt  | awk 'NR == 2 {print $4}'`

echo $address1

echo 'address1="'`cat svc_result.txt  | awk 'NR == 2 {print $4}'`'"' >> terraform.tfvars

echo 'address2="'`cat svc_result.txt  | awk 'NR == 3 {print $4}'`'"' >> terraform.tfvars

echo 'address3="'`cat svc_result.txt  | awk 'NR == 4 {print $4}'`'"' >> terraform.tfvars

echo "Running terraform to deploy VPN Connection"

terraform init

terraform apply --var-file="terraform.tfvars" -auto-approve

echo "All Resources Deployed, ipsec reload, restart"

ansible-playbook post_install.yml --extra-vars="address1=$address1"


echo "IP Tables configure"


