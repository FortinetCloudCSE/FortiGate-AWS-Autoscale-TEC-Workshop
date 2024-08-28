---
title: "Task 16: Cleanup"
weight: 7
---

* Start by removing all routes in the Workload VPC that point to the autoscale endpoints that we created in Task5. The Terraform destroy will fail if you try to remove the endpoints with existing routes pointing to the endpoints. 
* Log into your AWS account and navigate to the [**Console Home**](https://us-west-2.console.aws.amazon.com/console/home?region=us-west-2#).
* Click on the VPC icon

![](image-t16-1.png)

* Click on "Route tables" in the left pane

![](image-t16-2.png)

* Highlight the private route table for AZ1.
* Click the "Routes" tab at the bottom
* Click "Edit routes"

![](image-t16-3.png)

* Remove the default route that points to the GWLB endpoint in AZ1. If you want to put it back the way it was before our testing, point the default route to the NAT Gateway in the same AZ. We are just going to teardown all the VPC's, so it doesn't matter in this case. 
* Click "Save changes"

![](image-t16-4.png)

* Click on "Route tables" in the left pane

![](image-t16-2.png)

* Highlight the private route table for AZ2.
* Click the "Routes" tab at the bottom
* Click "Edit routes"

![](image-t16-5.png)

* Remove the default route that points to the GWLB endpoint in AZ1. If you want to put it back the way it was before our testing, point the default route to the NAT Gateway in the same AZ. We are just going to teardown all the VPC's, so it doesn't matter in this case. 
* Click "Save changes"

![](image-t16-6.png)

* Click on "Route tables" in the left pane

![](image-t16-2.png)

* Highlight the fwaas route table for AZ1.
* Click the "Routes" tab at the bottom
* Click "Edit routes"

![](image-t16-7.png)

* Remove the default route that points to the GWLB endpoint in AZ1. 
* Click "Save changes"

![](image-t16-8.png)

* Click on "Route tables" in the left pane

![](image-t16-2.png)

* Highlight the fwaas route table for AZ2.
* Click the "Routes" tab at the bottom
* Click "Edit routes"

![](image-t16-9.png)

* Remove the default route that points to the GWLB endpoint in AZ1. 
* Click "Save changes"

![](image-t16-10.png)

* Cleanup the terraform autoscale deployment. 
** ssh into the ec2 linux jumpbox using the IP address in your scratchpad.

![](image-t16-11.png)

  ``` ssh -i <keypair> ubuntu@<public ip> ```

** cd to the deployment directory

  ``` cd terraform-aws-cloud-modules/examples/spk_tgw_gwlb_asg_fgt_igw/ ```

** destroy the autoscale group using terraform destroy. (20-25 minutes)
** Wait for "destroy complete"

  ``` terraform destroy --auto-approve ```

![](image-t16-12.png)
![](image-t16-13.png)

* Now lets destroy the centralized egress workload vpc we created from AWS Cloudshell
* Log into your AWS account and navigate to the [**Console Home**](https://us-west-2.console.aws.amazon.com/console/home?region=us-west-2#).
* Click on the "AWS Cloudshell" icon
* change directory into the centralized egress directory
* issue the command to destroy the terraform deployment

  ``` cd FortiGate-AWS-Autoscale-TEC-Workshop/terraform/centralized_ingress_egress_east_west/ ```
  ``` terraform destroy --auto-approve ```

![](image-t16-14.png)
![](image-t16-15.png)

* Wait for "destroy complete"

![](image-t16-16.png)

* Cleanup the terraform state files and lock files.

  ``` rm -rf .terraform .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup ```

* This concludes this section and the workshop is complete.
