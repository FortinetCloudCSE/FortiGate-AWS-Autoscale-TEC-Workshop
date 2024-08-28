---
title: "Deploy a standard configuration FortiGate Autoscale group into the existing distributed egress workload vpc"
weight: 5
---
This section will deploy a standard configuration FortiGate Autoscale group using Fortinet Autoscale Terraform templates. These templates will create a security VPC and associated subnets, route tables, autoscale groups, and a single FortiGate Primary instance.The template will also deploy Gateway Load Balancer endoints into the specified subnets of the workload VPC. The security policy will be created on the single "Primary" FortiGate instance using the FortiGate GUI. 


