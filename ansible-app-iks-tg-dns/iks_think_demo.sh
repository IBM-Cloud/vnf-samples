#!/bin/bash

ibmcloud login -a cloud.ibm.com --apikey $RIAS_API_KEY -r us-south

echo "Logged in to Cloud"

ibmcloud ks cluster config -c iks-think-demo  --admin

echo  "Downloaded Kube Config"

ansible-playbook site.yml

echo -e "Deploying Application and NLB.. Please wait for sometime..\n\n"

sleep 30

echo "kubectl get pods"
kubectl get pods

echo "kubectl get svc"
kubectl get svc

kubectl get svc > svc_result.txt 

echo 'vpc_crn="crn:v1:bluemix:public:is:us-south:a/6991a6797b7b4754947b081d8dedc6e7::vpc:r006-db9af4fc-a205-49f8-b6f4-f8d6e39ace52"' > terraform.tfvars

echo 'dns_instance_id="fd54ad44-abf6-4208-920b-a0a7c6957c94"' >> terraform.tfvars

echo 'region="us-south"' >> terraform.tfvars

echo 'generation=2' >> terraform.tfvars

echo 'address1="'`cat svc_result.txt  | awk 'NR == 2 {print $4}'`'"' >> terraform.tfvars

echo 'address2="'`cat svc_result.txt  | awk 'NR == 3 {print $4}'`'"' >> terraform.tfvars

echo 'address3="'`cat svc_result.txt  | awk 'NR == 4 {print $4}'`'"' >> terraform.tfvars


echo "Running terraform to deploy Transit Gateway and Private DNS"

terraform init

terraform apply --var-file="terraform.tfvars" -auto-approve

echo "All Resources Deployed"
