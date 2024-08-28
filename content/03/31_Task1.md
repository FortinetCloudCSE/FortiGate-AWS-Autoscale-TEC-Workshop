---
title: "Task 1: Install Terraform in AWS Cloudshell"
weight: 1
---

* Log into your AWS account and navigate to the [**Console Home**](https://us-west-2.console.aws.amazon.com/console/home?region=us-west-2#).
* Click on the AWS CloudShell icon on the console navigation bar

![](image-t1-1.png)

* We are going to use the Terraform Version Manager to help install Terraform
* Clone the Terraform Version Manager repository

  ``` git clone https://github.com/tfutils/tfenv.git ~/.tfenv ```

![](image-t1-2.png)

* Make a new directory called ~/bin

  ``` mkdir ~/bin ```

* Make a symlink for tfenv/bin/* scripts into the path ~/bin 

  ``` ln -s ~/.tfenv/bin/* ~/bin ```

* With the Terraform Version Manager installed, we can now install Terraform. 

  ``` tfenv install ```
  
  ![](image-t1-3.png)

* This will install the latest version of Terraform for you. Take note of the installed version of terrform. In this case, the default version is 1.5.3. 
* To make this version the default version, use the following commmand
  
  ``` tfenv use 1.5.3 ```

 {{% notice info %}}
**Note:** The current version of terraform changes as newer patches are released. Just use the latest version of terraform for this workshop.
{{% /notice %}}

* Verify you are using the proper version of terraform 

  ``` terraform -v ```
  
  ![](image-t1-4.png) 

* This concludes this section.
