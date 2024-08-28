---
title: "Task 3: Protect the Workload VPC with Security Group Rules"
weight: 1
---

The network diagram for the distributed ingress vpc looks like this:

![](image-distriuted-ingress-with-nlb.png)

On deployment, the ec2 instances deployed in the private subnet of the distributed ingress workload vpc have open access to SSH and HTTPS. 
* Let's take a look at the security group for the linux instance. 
  * From Console Home, click on EC2
  * From EC2, click on Instances (running)
  * Choose the instance in AZ1
  * Click on the security tab for the instance
  * Click on the link to the security group

![](image-t3-1.png)
![](image-t3-2.png)
![](image-t3-3.png)

* On this screen, we can see that we are allowing SSH (tcp port 22) and HTTP (tcp port 80) from any IPv4 address. The instance is protected from login by the ssh keypair, but let's tighten the security up using the security group to prevent random access to the Apache server. 
  * Click on "Edit Inbound Rules" (yellow arrow)

![](image-t3-4.png)

* Click on the "Source" dropdown and change "Anywhere-IPv4" to "My IP" for the Inbound HTTP and Inbound SSH.
* Change the description from Anywhere to My IP
* Click "Save Rules"

 ![](image-t3-5.png)

* Now we have security rules to access our linux instances via SSH and HTTP from our Public IP. 

 ![](image-t3-6.png)

* We also have security rules that allow HTTP and SSH via the NLB to have access to the linux instances. The NLB has a Public IP in each AZ. This allows us to access the backend servers through the NLB and the access will be load balanced across each AZ. 

 ![](image-t3-7.png)

* Lookup the "Public IP" associated with each linux instance and bring up a browser to verify connectivity. You should see a slightly modified Default Apache2 Page that also shows the AZ of the response linux instance.

 ![](image-t3-9.png)
 ![](image-t3-9a.png)

* This was a small demonstration on managing security policy with security groups. A bit tedious don't you think? Now let's deploy a Fortigate Security Policy instance and manage security policy with a Next Generation Firewall. 

* This concludes this section.
