# vnf-samples. (Work under progress)


This repository contains sample terraform codes to create VNF instances with different configurations like Single NIC Instance, Multi NIC Instance, HA Instances etc.

Each of these use cases can be tested using Terraform CLI commands and IBM Cloud Schematics.

In order to test the code of a particular use case through the Terraform CLI commands, the Terraform CLI commands need to be run from the use case directory.

Similarly to test the use case from IBM Cloud Schematics, the path of the use case directory in this github repository need to be provided as the URL.

For example to test the one_nic_vsi_sample use case the URL to be used in the IBM Cloud Schematics will be https://github.com/IBM-Cloud/vnf-samples/tree/master/one_nic_vsi_sample

To test the use case in CLI, change directory to the respective folder of use case. Example: /Users/username/vnf-samples/one_nic_vsi_sample. Execute terraform commands in use case directory. 

Example:   

/Users/username/vnf-samples/one_nic_vsi_sample> terraform init

In order to use a particular use case in the content catalogue as a .tar.gz release file, copy the code of the specific use case in a separate repository and then use it as a .tar.gz release file. The repository content as such cannot be used in the content catalogue.

Follow the README for each of the use cases to get more details. 
