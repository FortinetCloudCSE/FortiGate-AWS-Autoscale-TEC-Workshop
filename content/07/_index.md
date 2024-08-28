---
title: "Create a Centralized Workload VPC using Terraform in AWS Cloudshell"
weight: 7
---
This section will create a centralized egress workload VPC in AWS using Terraform. The VPC will have dual workload VPC's and a single inspection/security VPC connected to a transit gateway. The spoke VPC's will egress to the inspection vpc through the transit gateway and egress to the internet through the inspection VPC's NAT Gateway. Subsequent tasks will  deploy a FortiGate Autoscale group and gateway load balancer (GWLB) and the traffic will be redirected to the FortiGate Autoscale Group for inspection. The VPC will be created in the us-west-2 (Oregon) region.

