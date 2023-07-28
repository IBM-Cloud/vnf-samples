- Click on IBM Cloud Catalog and then search for Checkpoint IaaS Security Management.

- Keep the deployment target, delivery method and product version as it is by default.


- Now configure your workspace with a unique name and a desired location.

- To fill the required input variables, refer to the description for the deployment parameters taken from the readme file. After filling all the required input variables, read and agree to the third-party terms and then click on Install.



- You can now see Cart creation in progress.


- After Cart creation is successful, Terraform commands start running.

- If it fails, check for Log and resolve the error. 
- Wait until the Applied plan is successful and the resource shows ‘Active’.

- From the left navigation menu, go to ‘VPC Infrastructure’ and click on ‘Virtual server instances’.

- You can see the name and details of the instance you just created. Note its Floating IP.



- Open your command prompt and run the command ‘ssh admin@<floating\_ip>’ to log into the system with this IP. 
- Then set a password by running the command ‘set user admin password’  

- Follow the steps in [CheckPointMgmtConfig.md](https://github.ibm.com/orion/vnf-vpc-docs/blob/master/Vendors/CheckPoint/UIConfiguration/CheckPointMgmtConfig.md) to configure the Checkpoint Management Server.
  - Note:
    - For Step 1, use the Floating IP from above.
    - For Step 2, use username as ‘admin’ and password as the one set above.
    - Step 5 can be skipped as new password has been set.

