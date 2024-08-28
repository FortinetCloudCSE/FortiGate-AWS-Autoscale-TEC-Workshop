---
title: "IaC Discussion Points"
weight: 2
---

## ***Discussion Points During a Demo - Chapter 3***

Fortinet provides a large library of infrastructure as code (IaC) templates to deploy baseline and iterate POC and production environments in public cloud.  IaC support includes Terraform, Ansible, and cloud-specific services such as Azure ARM, AWS Cloudformation, and Google Deployment templates. Terraform Providers are available for several Fortinet products to insert and iterate running configuration.

For more information, review the following:

* [FortiOS 7.2 Admin Guide](https://docs.fortinet.com/document/fortigate/7.2.2/administration-guide/763117/terraform-fortios-as-a-provider)

* [Terraform Providers](https://fndn.fortinet.net/index.php?/cloud/terraform/)

* [Ansible Modules](https://galaxy.ansible.com/fortinet)

### Advantages of Using AWS CloudShell for Deployment

AWS CloudShell is a browser-based shell that makes it easy to securely manage, explore, and interact with your AWS resources. CloudShell is pre-authenticated with your console credentials and common development and operations tools are pre-installed. CloudShell is available in all commercial AWS regions at no additional cost and provides an environment with preconfigured CLI tools and access to AWS services.  CloudShell provides a temporary 1 GB storage volume that is deleted after 120 minutes of inactivity.  CloudShell is a convenient method to deploy IaC templates for demonstrations and quick deployments.

### Alternative Methods of using Terraform in Production Environments

AWS Cloudshell is a nice environment for deploying demo environments. However, for production environments, it is recommended to use a local workstation or a CI/CD pipeline. If your customer is asking about how to deploy Terraform in production, you can point them to the following resources:

* https://aws.amazon.com/blogs/apn/terraform-beyond-the-basics-with-aws/

Be sure to point out that the Fortinet Terraform templates are free to use and modify.  These templates are designed to illustrate reference architectures in a demo environment only and may require modification to meet production requirements.

    
### Key questions during your demo 

When giving this TEC Workshop as a demo, the following questions will provide a basis for next steps and future meetings:

* Has your organization standardized on an IaC tool-set for infrastructure provisioning and iteration?
* How are the responsibilities for infrastructure assigned?  Does cloud network fall under a DevOps, Cloud Networking, or Application Delivery team, as examples?
* What is organizations view on how IaC can improve workflows?
* Is workflow automation in cloud and cross-organizational collaboration important within your cloud business?

***
