# vnf-samples. (Work under progress)


This repository contains sample terraform codes to create VNF instances with different configurations like Single NIC Instance, Multi NIC Instance, HA Instances etc.

Each of these use cases can be tested using Terraform CLI commands and IBM Cloud Schematics.

In order to test the code of a particular use case through the Terraform CLI commands, the Terraform CLI commands need to be run from the use case directory.

Similarly to test the use case frm IBM Cloud Schematics, the path of the use case directory in this github repository need to be provided as the URL.

For example to test the one_nic_vsi_sample use case the URL to be used in the IBM Cloud Schematics will be https://github.com/IBM-Cloud/vnf-samples/tree/master/one_nic_vsi_sample

Follow the README for each of the use cases to get more details.
