---
title: "Terraform Install and Deployment"
weight: 3
---

In this section, we will use AWS Cloudshell to install Terraform and deploy the Terraform templates that will be used to deploy the demo environment. AWS Cloudshell is a browser-based shell that is pre-configured to interact with AWS services. It is a great way to get started with AWS CLI and Terraform without having to install anything on your local machine. We will install Terraform on AWS Cloudshell and then use it to deploy the demo environment and Terraform will use tfenv to control the version of Terraform that is installed. AWS Cloudshell has a 1 GB disk storage limitation. This will prevent us from deploying larger templates or multiple templates from the same Cloudshell instance. For production use, it is recommended to install Terraform on your local machine and/or use it in a CI/CD pipeline to manage production environments.