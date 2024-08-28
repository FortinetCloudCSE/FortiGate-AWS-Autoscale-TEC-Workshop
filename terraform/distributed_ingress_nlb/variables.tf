variable "aws_region" {
  description = "The AWS region to use"
}
variable "availability_zone_1" {
  description = "Availability Zone 1 for VPC"
}
variable "availability_zone_2" {
  description = "Availability Zone 2 for VPC"
}
variable "cp" {
  description = "Customer Prefix to apply to all resources"
}
variable "env" {
  description = "The Tag Environment to differentiate prod/test/dev"
}
variable "acl" {
  description = "The S3 acl"
}
variable "keypair" {
  description = "Keypair for instances that support keypairs"
}
variable "vpc_name" {
    description = "Name of spoke VPC"
}
variable "vpc_cidr" {
    description = "CIDR for the whole VPC"
}
variable subnet_bits {
  description = "Number of bits in the network portion of the subnet CIDR"
}
variable "public_subnet_index" {
  description = "Index of the public subnet"
  default = 0
}
variable "gwlbe_subnet_index" {
  description = "Index of the gwlbe subnet"
  default = 1
}
variable "private_subnet_index" {
  description = "Index of the private subnet"
  default = 2
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
variable "ec2_sg_name" {
  description = "Linux Endpoint Security Group Name"
}
variable "linux_instance_name" {
  description = "Linux Endpoint Instance Name"
}

variable "linux_instance_type" {
  description = "Linux Endpoint Instance Type"
}
variable "linux_host_ip" {
  description = "Fortigate Host IP for all subnets"
}
