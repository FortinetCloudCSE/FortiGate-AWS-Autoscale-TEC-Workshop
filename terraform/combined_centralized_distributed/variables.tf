variable "aws_region" {
  description = "The AWS region to use"
}
variable "availability_zone_1" {
  description = "Availability Zone 1 for VPC"
}
variable "availability_zone_2" {
  description = "Availability Zone 2 for VPC"
}
variable subnet_bits {
  description = "Number of bits in the network portion of the subnet CIDR"
}
variable "public_subnet_index" {
  description = "Index of the public subnet"
  default = 0
}
variable "gwlbe_subnet_index" {
  description = "Index of the management subnet"
  default = 1
}
variable "private_subnet_index" {
  description = "Index of the private subnet"
  default = 2
}
variable "tgw_subnet_index" {
  description = "Index of the Transit Gateway Attachment subnet"
  default = 3
}
variable "keypair" {
  description = "Keypair for instances that support keypairs"
}
variable "my_ip" {
    description = "CIDR for my IP to restrict security group"
}
variable "cp" {
  description = "Customer Prefix to apply to all resources"
}
variable "env" {
  description = "The Tag Environment to differentiate prod/test/dev"
}
variable "vpc_cidr_ns_inspection" {
    description = "CIDR for the whole NS inspection VPC"
}
variable "vpc_cidr_ew_inspection" {
    description = "CIDR for the whole EW inspection VPC"
}
variable "vpc_cidr_east" {
    description = "CIDR for the whole east VPC"
}
variable "vpc_cidr_spoke" {
    description = "Super-Net CIDR for the spoke VPC's"
}
variable "vpc_cidr_jump_box" {
    description = "CIDR for the jump box subnet"
}
variable "vpc_cidr_east_private_az1" {
    description = "CIDR for the AZ1 private subnet in East VPC"
}
variable "vpc_cidr_east_private_az2" {
    description = "CIDR for the AZ2 private subnet in East VPC"
}
variable "vpc_cidr_west" {
    description = "CIDR for the whole west VPC"
}
variable "vpc_cidr_west_private_az1" {
    description = "CIDR for the AZ1 private subnet in west VPC"
}
variable "vpc_cidr_west_private_az2" {
    description = "CIDR for the AZ2 private subnet in west VPC"
}
variable "attach_to_tgw_name" {
  description = "Name of the TGW to attach to"
  type        = string
  default     = ""
}
variable "endpoint_name_az1" {
  description = "Name of the gwlb endpoint to route to in AZ1"
  type        = string
  default     = ""
}
variable "endpoint_name_az2" {
  description = "Name of the gwlb endpoint to route to in AZ2"
  type        = string
  default     = ""
}
variable "ew_endpoint_name_az1" {
  description = "Name of the gwlb endpoint to route to in AZ1"
  type        = string
  default     = ""
}
variable "ew_endpoint_name_az2" {
  description = "Name of the gwlb endpoint to route to in AZ2"
  type        = string
  default     = ""
}
variable "enable_tgw_attachment_subnet" {
  description = "Boolean to allow creation of TGW Attachment subnet in each AZ of Inspection VPC"
  type        = bool
}
variable "enable_tgw_attachment" {
  description = "Allow Inspection VPC to attach to an existing TGW"
  type        = bool
}
variable "enable_jump_box" {
  description = "Boolean to allow creation of Linux Jump Box in Inspection VPC"
  type        = bool
}
#
# This boolean creates the resources a customer might have in an existing VPC. I don't have existing resources, so
# this boolean will allow the creation of a TGW, VPC east, and VPC west. For testing only.
#
variable "enable_build_existing_vpc" {
  description = "Boolean to allow creation of resources associated with an existing VPC"
  type        = bool
}
variable "enable_jump_box_public_ip" {
  description = "Boolean to allow creation of Linux Jump Box public IP in Inspection VPC"
  type        = bool
}
variable "enable_nat_gateway" {
  description = "Boolean to allow creation of nat gateways in each AZ of Inspection VPC"
  type        = bool
}
variable "enable_fortimanager" {
  description = "Boolean to allow creation of FortiManager in Inspection VPC"
  type        = bool
}
variable "enable_fortimanager_public_ip" {
  description = "Boolean to allow creation of FortiManager public IP in Inspection VPC"
  type        = bool
}
variable "fortimanager_instance_type" {
  description = "Instance type for fortimanager"
}
variable "fortimanager_os_version" {
  description = "Fortimanager OS Version for the AMI Search String"
}
variable "fortimanager_host_ip" {
  description = "Fortimanager IP Address"
}
variable "enable_fortianalyzer" {
  description = "Boolean to allow creation of FortiAnalyzer in Inspection VPC"
  type        = bool
}
variable "fortianalyzer_instance_type" {
  description = "Instance type for fortianalyzer"
}
variable "fortianalyzer_os_version" {
  description = "Fortianalyzer OS Version for the AMI Search String"
}
variable "fortianalyzer_host_ip" {
  description = "Fortianalyzer IP Address"
}
variable "enable_fortianalyzer_public_ip" {
  description = "Boolean to allow creation of FortiAnalyzer public IP in Inspection VPC"
  type        = bool
}
variable "fortigate_asg_password" {
  description = "Password for the Fortigate ASG"
}
variable "cidr_for_access" {
  description = "CIDR to use for security group access"
}
variable "acl" {
  description = "The S3 acl"
}
variable "linux_instance_type" {
  description = "Linux Endpoint Instance Type"
}
variable "linux_instance_name_distributed" {
  description = "Linux Distributed Endpoint Instance Name"
}
variable "ec2_sg_name_distributed" {
  description = "Linux Distributed Endpoint Security Group Name"
}
variable "linux_host_ip" {
  description = "Fortigate Host IP for all subnets"
}

variable "vpc_cidr_distributed" {
    description = "CIDR for the whole distributed VPC"
}
variable "vpc_name_distributed" {
    description = "Name of distributed VPC"
}
variable "enable_nlb" {
  description = "Boolean to allow creation of nlb and associated resources"
  type        = bool
  default     = false
}
variable "enable_public_ips" {
  description = "Boolean to Enable an Elastic IP on Public Interface"
  default = true
}
variable "use_preallocated_elastic_ip" {
  description = "Boolean to Enable an Elastic IP on Public Interface"
  default = false
}