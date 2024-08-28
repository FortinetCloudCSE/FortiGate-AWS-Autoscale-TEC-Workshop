---
title: "Managing Security with AWS Security Groups - Discussion Points"
weight: 2
---

## ***Discussion Points During a Demo - Chapter 3***

Key reasons for using a Next Generation Firewall in the cloud:

* AWS Security Groups are static and do not provide dynamic security policies that can keep up with the dynamic nature of cloud infrastructure. 
* Building dynamic policies with AWS Security Groups is a manual process that is not scalable.
* AWS Security Groups do not use threat intelligence to block known bad IP addresses and new or unknown threat vectors like a Next Generation Firewall does.
* Updating AWS Security Groups across a large deployment is prone to error and omission.
* AWS Security Groups are not managed through a single pane of glass across multi-cloud and on-premises environments.
    
### Key questions during your demo 

When giving this TEC Workshop as a demo, the following questions will point out that AWS Security Groups are not dynamic enough to keep up with changing cloud infrastructure and do not inspect the traffic at layers 4-7 like a Next Generation Firewall does:

* Do you plan to provide deep inspection of traffic in your cloud environment? Security Groups are limited to layer 4 inspection only. FortiGate firewalls can apply UTM inspection profiles to traffic flows and protect against a wide range of new or unknown threat vectors.
* Do you plan to provide dynamic security policies that can keep up with the dynamic nature of cloud infrastructure? Security Groups are static and do not provide dynamic security policies. FortiGate objects can be dynamically built and updated based on tags and other attributes that scales with a changing cloud infrastructure.
* Do you plan to provide a single pane of glass for security policy management across your cloud and on-premises environments? Security Groups are limited to AWS only and do not provide a single pane of glass for security policy management across multi-cloud and on-premises environments.

***
