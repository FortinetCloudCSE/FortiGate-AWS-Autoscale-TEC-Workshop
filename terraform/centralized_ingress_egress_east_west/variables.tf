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
  description = "Index of the gwlb endpoint subnet"
  default = 1
}
variable "private_subnet_index" {
  description = "Index of the private subnet"
  default = 2
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
variable "vpc_cidr_inspection" {
    description = "CIDR for the whole inspection VPC"
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
variable "fortimanager_instance_type" {
  description = "Instance type for fortimanager"
}
variable "fortimanager_os_version" {
  description = "Fortimanager OS Version for the AMI Search String"
}
variable "fortimanager_host_ip" {
  description = "Fortimanager IP Address"
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
variable "cidr_for_access" {
  description = "CIDR to use for security group access"
}
variable "acl" {
  description = "The S3 acl"
}
variable "linux_instance_type" {
  description = "Linux Endpoint Instance Type"
}
variable "linux_host_ip" {
  description = "Fortigate Host IP for all subnets"
}
